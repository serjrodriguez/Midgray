//
//  ManualLightSensor.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
@testable import Midgray

struct ManualLightSensor: LightSensing {
    private let stream: AsyncThrowingStream<CameraReading, any Error>
    private let continuation: AsyncThrowingStream<CameraReading, any Error>.Continuation

    init() {
        (stream, continuation) = AsyncThrowingStream.makeStream(of: CameraReading.self)
    }

    func readings() -> AsyncThrowingStream<CameraReading, any Error> {
        stream
    }

    func send(_ reading: CameraReading) {
        continuation.yield(reading)
    }
}
