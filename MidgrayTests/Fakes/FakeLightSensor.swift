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

    func readings() -> AsyncStream<CameraReading> {
        let scripted = scriptedReadings
        return AsyncStream { continuation in
            for reading in scripted { continuation.yield(reading) }
            continuation.finish()
        }
    }
}
