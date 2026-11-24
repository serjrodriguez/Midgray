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
    
    init(sensor: any LightSensing, smoother: EVSmoother) {
        self.sensor = sensor
        self.smoother = smoother
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
