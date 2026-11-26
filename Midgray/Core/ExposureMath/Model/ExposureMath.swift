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
    
    static func exposureTime(ev100: Double, aperture fNumber: Double, iso: Double) -> Double? {
        guard ev100.isFinite, fNumber > 0, iso > 0 else { return nil }
        
        return 100 * fNumber * fNumber / (iso * exp2(ev100))
    }
    
    static func aperture(ev100: Double, exposureTime: Double, iso: Double) -> Double? {
        guard ev100.isFinite, exposureTime > 0, iso > 0 else { return nil }
        
        return sqrt(exposureTime * iso * exp2(ev100) / 100)
    }
    
    static func iso(ev100: Double, aperture fNumber: Double, exposureTime: Double) -> Double? {
        guard ev100.isFinite, fNumber > 0, exposureTime > 0 else { return nil }
        
        return 100 * fNumber * fNumber / (exposureTime * exp2(ev100))
    }
}
