//
//  MidgrayApp.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 17/11/26.
//

import SwiftUI
import SrdzPermissionsCamera

@main
struct MidgrayApp: App {
    @State private var viewModel = MeterViewModel(sensor: MidgrayApp.makeSensor(), smoother: EVSmoother()!)

    @State private var permissions = CameraPermissionsViewModel(permission: CameraPermission.live)

    var body: some Scene {
        WindowGroup {
            RootView(permissions: permissions, meter: viewModel)
        }
    }

    private static func makeSensor() -> any LightSensing {
        #if targetEnvironment(simulator)
        SimulatedLightSensor(offsets: [0, 0.3, 0.6, 0.3, 0, -0.3, -0.6, -0.3], interval: .milliseconds(400))
        #else
        MeterCamera()
        #endif
    }
}
