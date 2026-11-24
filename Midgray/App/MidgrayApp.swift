//
//  MidgrayApp.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 17/11/26.
//

import SwiftUI

@main
struct MidgrayApp: App {
    @State private var viewModel = MeterViewModel(sensor: MidgrayApp.makeSensor(), smoother: EVSmoother()!)

    var body: some Scene {
        WindowGroup {
            MeterView(viewModel: viewModel)
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
