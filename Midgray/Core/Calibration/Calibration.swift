//
//  Calibration.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated enum Calibration {
    static let range: ClosedRange<Double> = -2...2
    static let stepsPerEV = 10

    static func normalized(_ value: Double) -> Double {
        guard value.isFinite else { return 0 }

        let steps = (value * Double(stepsPerEV)).rounded()
        let clamped = min(max(steps, range.lowerBound * Double(stepsPerEV)), range.upperBound * Double(stepsPerEV))
        return clamped / Double(stepsPerEV)
    }

    static func stepped(_ value: Double, by steps: Int) -> Double {
        normalized(normalized(value) + Double(steps) / Double(stepsPerEV))
    }
}
