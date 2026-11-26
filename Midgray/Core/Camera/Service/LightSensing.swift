import Foundation
import CoreGraphics

nonisolated protocol LightSensing: Sendable {
    var lenses: [CameraLens] { get }

    func readings() -> AsyncThrowingStream<CameraReading, any Error>
    func selectLens(_ lens: CameraLens) async
    func setMeteringPoint(_ point: CGPoint?) async
}

nonisolated extension LightSensing {
    var lenses: [CameraLens] { [] }

    func selectLens(_ lens: CameraLens) async {}

    func setMeteringPoint(_ point: CGPoint?) async {}
}
