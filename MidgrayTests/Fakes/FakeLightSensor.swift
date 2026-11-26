//
//  FakeLightSensor.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation
@testable import Midgray

struct FakeLightSensor: LightSensing {
    let scriptedReadings: [CameraReading]

    func readings() -> AsyncThrowingStream<CameraReading, any Error> {
        let scripted = scriptedReadings
        return AsyncThrowingStream { continuation in
            for reading in scripted { continuation.yield(reading) }
            continuation.finish()
        }
    }
}
