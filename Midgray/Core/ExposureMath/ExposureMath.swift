//
//  ExposureMath.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 19/11/26.
//

import Foundation

nonisolated enum ExposureMath {
    static func ev100(aperture fNumber: Double, exposureTime: Double, iso: Double) -> Double? {
        guard fNumber > 0, exposureTime > 0, iso > 0 else { return nil }
        
        return log2((fNumber * fNumber) / exposureTime) - log2(iso / 100)
    }
}
