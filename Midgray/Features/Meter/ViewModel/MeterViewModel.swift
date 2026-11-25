//
//  MeterViewModel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
import Observation

@Observable
final class MeterViewModel {
    nonisolated static let compensationRange: ClosedRange<Double> = -3...3
    nonisolated static let compensationValues: [Double] = (-9...9).map { Double($0) / 3 }
    nonisolated static let outOfRangeThreshold: Double = 1
    nonisolated static let stabilizationThreshold: Double = 0.15
    nonisolated static let lensSettleDelay: Duration = .milliseconds(300)

    var mode: ExposureMode
    var aperture: Double
    var shutterSpeed: Double
    var baseISO: Double
    
    private(set) var compensation: Double = 0
    private(set) var calibration: Double = 0
    private(set) var autoAperture: Double
    private(set) var isHeld = false
    private(set) var selectedLens: CameraLens?
    private(set) var isSwitchingLens = false

    private let sensor: any LightSensing
    private let lensSettleDelay: Duration
    private var smoother: EVSmoother
    private var stabilizer = EVStabilizer(threshold: MeterViewModel.stabilizationThreshold)!
    private var task: Task<Void, Never>?
    private var latest: (ev: Double, offset: Double)?

    init(sensor: any LightSensing,
         smoother: EVSmoother,
         mode: ExposureMode = .auto,
         aperture: Double = 5.6,
         shutterSpeed: Double = 1.0 / 125,
         baseISO: Double = 100,
         autoAperture: Double = 5.6,
         lensSettleDelay: Duration = MeterViewModel.lensSettleDelay) {
        self.sensor = sensor
        self.lensSettleDelay = lensSettleDelay
        self.smoother = smoother
        self.mode = mode
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.baseISO = baseISO
        self.autoAperture = autoAperture
        self.selectedLens = sensor.lenses.first { $0.kind == .wide } ?? sensor.lenses.first
    }

    var lenses: [CameraLens] { sensor.lenses }

    var state: MeterState {
        guard let latest else { return .idle }

        let calibratedEV = latest.ev + calibration
        let compensatedEV = calibratedEV - compensation
        let readout = MeterReadout(
            ev: calibratedEV,
            compensatedEV: compensatedEV,
            suggestion: ExposureSuggestion.suggestion(ev100: compensatedEV, baseISO: baseISO, priority: priority),
            equivalents: ExposureSuggestion.equivalents(ev100: compensatedEV, iso: baseISO)
        )

        return abs(latest.offset) > Self.outOfRangeThreshold ? .outOfRange(readout) : .measuring(readout)
    }

    func apply(_ settings: MeterSettings) {
        calibration = Calibration.normalized(settings.calibration)

        if let id = settings.defaultLensID, let lens = lenses.first(where: { $0.id == id }) {
            selectLens(lens)
        }
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
                guard !isHeld else { continue }
                guard let value = reading.ev100,
                      let smoothed = smoother.add(value),
                      let stable = stabilizer.add(smoothed) else { continue }

                latest = (stable, reading.exposureTargetOffset)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        smoother.reset()
        stabilizer.reset()
        latest = nil
        isHeld = false
    }

    func selectLens(_ lens: CameraLens) {
        guard lenses.contains(lens), lens != selectedLens else { return }

        selectedLens = lens
        smoother.reset()
        stabilizer.reset()

        isSwitchingLens = true

        let sensor = sensor
        let delay = lensSettleDelay
        Task {
            await sensor.selectLens(lens)
            try? await Task.sleep(for: delay)
            isSwitchingLens = false
        }
    }

    func toggleHold() {
        if isHeld {
            isHeld = false
            smoother.reset()
            stabilizer.reset()
        } else if latest != nil {
            isHeld = true
        }
    }

    func selectAutoAperture(_ value: Double) {
        guard value.isFinite, value > 0 else { return }
        autoAperture = value
    }
}

private extension MeterViewModel {
    var priority: ExposurePriority {
        switch mode {
        case .auto:
            .aperture(autoAperture)
        case .aperture:
            .aperture(aperture)
        case .shutter:
            .shutter(shutterSpeed)
        case .iso:
            .iso(aperture: aperture, shutter: shutterSpeed)
        }
    }
}
