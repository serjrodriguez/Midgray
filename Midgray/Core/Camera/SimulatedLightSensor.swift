//
//  SimulatedLightSensor.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated struct SimulatedLightSensor: LightSensing {
    let offsets: [Double]
    let interval: Duration

    init(offsets: [Double] = [0], interval: Duration = .milliseconds(100)) {
        self.offsets = offsets
        self.interval = interval
    }

    func readings() -> AsyncStream<CameraReading> {
        let offsets = offsets
        let interval = interval

        return AsyncStream { continuation in
            let task = Task {
                guard !offsets.isEmpty else {
                    continuation.finish()
                    return
                }

                var index = 0
                while !Task.isCancelled {
                    continuation.yield(CameraReading(
                        aperture: 16,
                        exposureTime: 1.0 / 125,
                        iso: 100,
                        exposureTargetOffset: offsets[index % offsets.count]
                    ))
                    index += 1
                    try? await Task.sleep(for: interval)
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
