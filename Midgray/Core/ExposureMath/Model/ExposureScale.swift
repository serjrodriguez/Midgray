//
//  ExposureScale.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 19/11/26.
//

import Foundation

nonisolated enum ExposureScale {
    static let apertures: [Double] = [
        1.0, 1.1, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.5, 2.8, 3.2, 3.5, 4.0, 4.5, 5.0,
        5.6, 6.3, 7.1, 8, 9, 10, 11, 13, 14, 16, 18, 20, 22, 25, 29, 32
    ]

    static let shutterSpeeds: [Double] = [
        1.0 / 4000, 1.0 / 3200, 1.0 / 2500, 1.0 / 2000, 1.0 / 1600, 1.0 / 1250,
        1.0 / 1000, 1.0 / 800, 1.0 / 640, 1.0 / 500, 1.0 / 400, 1.0 / 320,
        1.0 / 250, 1.0 / 200, 1.0 / 160, 1.0 / 125, 1.0 / 100, 1.0 / 80,
        1.0 / 60, 1.0 / 50, 1.0 / 40, 1.0 / 30, 1.0 / 25, 1.0 / 20,
        1.0 / 15, 1.0 / 13, 1.0 / 10, 1.0 / 8, 1.0 / 6, 1.0 / 5,
        1.0 / 4, 0.3, 0.4, 0.5, 0.6, 0.8,
        1, 1.3, 1.6, 2, 2.5, 3, 4, 5, 6, 8, 10, 13, 15, 20, 25, 30
    ]

    static let isoValues: [Double] = [
        50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000,
        1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 10000, 12800
    ]

    static func nearest(to value: Double, in scale: [Double]) -> Double? {
        guard value > 0 else { return nil }

        return scale.min { abs(log2($0 / value)) < abs(log2($1 / value)) }
    }

    static func step(_ value: Double, by offset: Int, in scale: [Double]) -> Double? {
        guard let current = nearest(to: value, in: scale),
              let index = scale.firstIndex(of: current)
        else { return nil }

        return scale[min(max(index + offset, 0), scale.count - 1)]
    }
}
