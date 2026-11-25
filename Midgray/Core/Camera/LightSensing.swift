import Foundation

nonisolated protocol LightSensing: Sendable {
    var lenses: [CameraLens] { get }

    func readings() -> AsyncStream<CameraReading>
    func selectLens(_ lens: CameraLens) async
}

nonisolated extension LightSensing {
    var lenses: [CameraLens] { [] }

    func selectLens(_ lens: CameraLens) async {}
}
