//
//  MeterSettings.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated struct MeterSettings: Equatable, Sendable {
    var calibration: Double
    var defaultLensID: String?

    static let standard = MeterSettings(calibration: 0, defaultLensID: nil)
}
