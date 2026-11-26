//
//  FailingLightSensor.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import Synchronization
@testable import Midgray

final class FailingLightSensor: LightSensing {
    private let attempts = Mutex(0)
    private let failures: Int
    private let reading: CameraReading

    init(failures: Int, reading: CameraReading) {
        self.failures = failures
        self.reading = reading
    }

    func readings() -> AsyncThrowingStream<CameraReading, any Error> {
        let attempt = attempts.withLock { count in
            count += 1
            return count
        }
        let fails = attempt <= failures
        let reading = reading

        return AsyncThrowingStream { continuation in
            if fails {
                continuation.finish(throwing: LightSensingError.cameraUnavailable)
            } else {
                continuation.yield(reading)
                continuation.finish()
            }
        }
    }
}
