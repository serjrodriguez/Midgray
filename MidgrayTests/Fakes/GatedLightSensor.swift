//
//  GatedLightSensor.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import Foundation
@testable import Midgray

struct GatedLightSensor: LightSensing {
    let lenses: [CameraLens]
    let heldLens: CameraLens
    private let gate = AsyncStream.makeStream(of: Void.self)

    init(lenses: [CameraLens], heldLens: CameraLens) {
        self.lenses = lenses
        self.heldLens = heldLens
    }

    func readings() -> AsyncThrowingStream<CameraReading, any Error> {
        AsyncThrowingStream { $0.finish() }
    }

    func selectLens(_ lens: CameraLens) async {
        guard lens == heldLens else { return }
        for await _ in gate.stream { break }
    }

    func release() {
        gate.continuation.yield()
    }
}
