//
//  ManualLightSensor.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
@testable import Midgray

struct ManualLightSensor: LightSensing {
    private let stream: AsyncStream<CameraReading>
    private let continuation: AsyncStream<CameraReading>.Continuation

    init() {
        (stream, continuation) = AsyncStream.makeStream(of: CameraReading.self)
    }

    func readings() -> AsyncStream<CameraReading> {
        stream
    }

    func send(_ reading: CameraReading) {
        continuation.yield(reading)
    }
}
