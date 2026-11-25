//
//  MidgrayApp.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 17/11/26.
//

import SwiftUI
import AVFoundation
import SrdzPermissionsCamera

@main
struct MidgrayApp: App {
    @State private var viewModel: MeterViewModel
    @State private var permissions = CameraPermissionsViewModel(permission: CameraPermission.live)
    private let previewSession: AVCaptureSession?

    init() {
        let (sensor, session) = MidgrayApp.makeSensor()
        _viewModel = State(initialValue: MeterViewModel(sensor: sensor, smoother: EVSmoother()!))
        previewSession = session
    }

    var body: some Scene {
        WindowGroup {
            RootView(permissions: permissions, meter: viewModel, previewSession: previewSession)
        }
    }

    #if targetEnvironment(simulator)
    private static let simulatedLenses = [
        CameraLens(id: "ultraWide", kind: .ultraWide, zoomFactor: 0.5),
        CameraLens(id: "wide", kind: .wide, zoomFactor: 1),
        CameraLens(id: "telephoto", kind: .telephoto, zoomFactor: 3)
    ]
    #endif

    private static func makeSensor() -> (any LightSensing, AVCaptureSession?) {
        #if targetEnvironment(simulator)
        (SimulatedLightSensor(offsets: [0, 0.3, 0.6, 0.3, 0, -0.3, -0.6, -0.3], interval: .milliseconds(400), lenses: simulatedLenses), nil)
        #else
        let camera = MeterCamera()
        return (camera, camera.session)
        #endif
    }
}
