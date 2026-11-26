//
//  EVStabilizer.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated struct EVStabilizer: Sendable {
    let threshold: Double
    private(set) var value: Double?

    init?(threshold: Double = 0.15) {
        guard threshold.isFinite, threshold >= 0 else { return nil }

        self.threshold = threshold
    }

    @discardableResult
    mutating func add(_ ev: Double) -> Double? {
        guard ev.isFinite else { return value }

        if let value, abs(ev - value) < threshold {
            return value
        }

        value = ev
        return ev
    }

    mutating func reset() {
        value = nil
    }
}
