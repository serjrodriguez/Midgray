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
    private(set) var ev: Double?
    
    private let sensor: any LightSensing
    private var smoother: EVSmoother
    private var task: Task<Void, Never>?
    
    var priority: ExposurePriority
    var baseISO: Double
    var suggestion: ExposureSuggestion? {
        guard let ev else { return nil }

        return ExposureSuggestion.suggestion(ev100: ev, baseISO: baseISO, priority: priority)
    }
    var equivalents: [ExposureSuggestion] {
        guard let ev else { return [] }

        return ExposureSuggestion.equivalents(ev100: ev, iso: baseISO)
    }

    init(sensor: any LightSensing,
         smoother: EVSmoother,
         priority: ExposurePriority = .aperture(5.6),
         baseISO: Double = 100) {
        self.sensor = sensor
        self.smoother = smoother
        self.baseISO = baseISO
        self.priority = priority
    }
    
    func start() {
        stop()

        let readings = sensor.readings()

        task = Task { [weak self] in
            for await reading in readings {
                guard let self else { return }
                guard let value = reading.ev100 else { continue }

                ev = smoother.add(value)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        smoother.reset()
        ev = nil
    }
}
