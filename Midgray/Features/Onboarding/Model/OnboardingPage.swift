//
//  OnboardingPage.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated enum OnboardingPage: CaseIterable, Hashable, Sendable {
    case measure
    case modes
    case metering
    case camera

    var symbol: String {
        switch self {
        case .measure: "sun.max"
        case .modes: "camera.aperture"
        case .metering: "viewfinder"
        case .camera: "camera.fill"
        }
    }
}
