//
//  MeterViewModel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
import Observation

nonisolated struct MeterReadout: Equatable {
    let ev: Double
    let compensatedEV: Double
    let suggestion: ExposureSuggestion?
    let equivalents: [ExposureSuggestion]
}

nonisolated enum MeterState: Equatable {
    case idle
    case measuring(MeterReadout)
    case outOfRange(MeterReadout)
}

@Observable
final class MeterViewModel {
    private var ev: Double?
    private var exposureOffset: Double?
    
    private let sensor: any LightSensing
    private var smoother: EVSmoother
    private var task: Task<Void, Never>?
    private var priority: ExposurePriority {
        switch mode {
        case .auto:
            .aperture(Self.autoAperture)
        case .aperture:
            .aperture(aperture)
        case .shutter:
            .shutter(shutterSpeed)
        case .iso:
            .iso(aperture: aperture, shutter: shutterSpeed)
        }
    }

    var baseISO: Double
    var mode: ExposureMode = .auto
    var aperture: Double
    var shutterSpeed: Double
    private(set) var compensation: Double = 0

    nonisolated static let compensationRange: ClosedRange<Double> = -3...3
    nonisolated static let outOfRangeThreshold: Double = 1
    nonisolated static let autoAperture: Double = 5.6

    private var compensatedEV: Double? {
        ev.map { $0 - compensation }
    }

    private var suggestion: ExposureSuggestion? {
        guard let compensatedEV else { return nil }
        return ExposureSuggestion.suggestion(ev100: compensatedEV, baseISO: baseISO, priority: priority)
    }

    private var equivalents: [ExposureSuggestion] {
        guard let compensatedEV else { return [] }
        return ExposureSuggestion.equivalents(ev100: compensatedEV, iso: baseISO)
    }

    var state: MeterState  {
        guard let ev = ev,
              let compensatedEV = compensatedEV
        else { return MeterState.idle }

        let readout = MeterReadout(
            ev: ev,
            compensatedEV: compensatedEV,
            suggestion: suggestion,
            equivalents: equivalents
        )

        if let exposureOffset, abs(exposureOffset) > Self.outOfRangeThreshold {
            return MeterState.outOfRange(readout)
        }

        return MeterState.measuring(readout)
    }

    init(sensor: any LightSensing,
         smoother: EVSmoother,
         mode: ExposureMode = .auto,
         aperture: Double = 5.6,
         shutterSpeed: Double = 1.0 / 125,
         baseISO: Double = 100) {
        self.sensor = sensor
        self.smoother = smoother
        self.baseISO = baseISO
        self.mode = mode
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
    }
    
    func setCompensation(_ value: Double) {
        guard value.isFinite else { return }

        let stepped = (value * 3).rounded() / 3
        compensation = min(max(stepped, Self.compensationRange.lowerBound), Self.compensationRange.upperBound)
    }

    func start() {
        stop()

        let readings = sensor.readings()

        task = Task { [weak self] in
            for await reading in readings {
                guard let self else { return }
                guard let value = reading.ev100 else { continue }

                ev = smoother.add(value)
                exposureOffset = reading.exposureTargetOffset
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        smoother.reset()
        ev = nil
        exposureOffset = nil
    }
}
