//
//  EVSmoother.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation

nonisolated struct EVSmoother: Sendable {
    let smoothing: Double
    private(set) var value: Double?

    init?(smoothing: Double = 0.2) {
        guard smoothing.isFinite, smoothing > 0, smoothing <= 1 else { return nil }

        self.smoothing = smoothing
    }

    @discardableResult
    mutating func add(_ ev: Double) -> Double? {
        guard ev.isFinite else { return value }

        let smoothed = value.map { $0 + smoothing * (ev - $0) } ?? ev
        value = smoothed
        return smoothed
    }

    mutating func reset() {
        value = nil
    }
}
