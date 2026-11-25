//
//  RecordingLightSensor.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
import CoreGraphics
import Synchronization
@testable import Midgray

final class RecordingLightSensor: LightSensing {
    let lenses: [CameraLens]
    private let selections = Mutex<[CameraLens]>([])
    private let points = Mutex<[CGPoint?]>([])

    init(lenses: [CameraLens]) {
        self.lenses = lenses
    }

    var selectedLenses: [CameraLens] {
        selections.withLock { $0 }
    }

    var meteringPoints: [CGPoint?] {
        points.withLock { $0 }
    }

    func readings() -> AsyncStream<CameraReading> {
        AsyncStream { $0.finish() }
    }

    func selectLens(_ lens: CameraLens) async {
        selections.withLock { $0.append(lens) }
    }

    func setMeteringPoint(_ point: CGPoint?) async {
        points.withLock { $0.append(point) }
    }
}
