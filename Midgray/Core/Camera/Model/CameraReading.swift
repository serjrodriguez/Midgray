//
//  CameraReading.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation

nonisolated struct CameraReading: Equatable, Sendable {
    let aperture: Double
    let exposureTime: Double
    let iso: Double
    let exposureTargetOffset: Double
    
    var ev100: Double? {
        guard exposureTargetOffset.isFinite,
              let settingsEV = ExposureMath.ev100(aperture: aperture, exposureTime: exposureTime, iso: iso)
        else { return nil }
        
        return settingsEV + exposureTargetOffset
    }
}
