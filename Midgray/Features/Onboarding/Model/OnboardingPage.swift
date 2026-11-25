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
    case adjust
    case camera

    var symbol: String {
        switch self {
        case .measure: "sun.max"
        case .modes: "camera.aperture"
        case .adjust: "plusminus"
        case .camera: "camera.fill"
        }
    }
}
