//
//  ExposureFormatter.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated enum ExposureFormatter {
    private static let fractionThreshold = 0.25

    static func aperture(_ value: Double, locale: Locale = .current) -> String {
        let digits = value >= 10 ? 0...0 : 0...1
        return "f/" + value.formatted(.number.precision(.fractionLength(digits)).locale(locale))
    }

    static func exposureTime(_ value: Double, locale: Locale = .current) -> String {
        guard value > 0 else { return "" }

        return value <= fractionThreshold
            ? fraction(value, locale: locale) + " s"
            : seconds(value, locale: locale) + " s"
    }

    static func equivalent(aperture: Double, exposureTime: Double, locale: Locale = .current) -> String {
        guard exposureTime > 0 else { return "" }

        let time = exposureTime <= fractionThreshold
            ? fraction(exposureTime, locale: locale)
            : seconds(exposureTime, locale: locale) + " s"

        return self.aperture(aperture, locale: locale) + " · " + time
    }

    static func iso(_ value: Double, locale: Locale = .current) -> String {
        "ISO " + value.formatted(.number.precision(.fractionLength(0)).grouping(.never).locale(locale))
    }

    static func ev(_ value: Double, locale: Locale = .current) -> String {
        "EV " + value.formatted(.number.precision(.fractionLength(1)).locale(locale))
    }

    private static func fraction(_ value: Double, locale: Locale) -> String {
        let denominator = (1 / value).rounded()
        return "1/" + denominator.formatted(.number.precision(.fractionLength(0)).grouping(.never).locale(locale))
    }

    private static func seconds(_ value: Double, locale: Locale) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)).locale(locale))
    }
}
