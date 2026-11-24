//
//  ExposureFormatterTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
import Testing
@testable import Midgray

struct ExposureFormatterTests {
    static let english = Locale(identifier: "en_US")
    static let spanish = Locale(identifier: "es_ES")

    static let apertures: [(Double, String)] = [
        (1.0, "f/1"), (1.4, "f/1.4"), (1.8, "f/1.8"), (2.0, "f/2"), (2.8, "f/2.8"),
        (5.6, "f/5.6"), (8, "f/8"), (9, "f/9"), (11, "f/11"), (16, "f/16"), (22, "f/22"), (32, "f/32")
    ]

    @Test(arguments: ExposureFormatterTests.apertures)
    func formatsApertures(value: Double, expected: String) {
        #expect(ExposureFormatter.aperture(value, locale: Self.english) == expected)
    }

    static let exposureTimes: [(Double, String)] = [
        (1.0 / 4000, "1/4000 s"), (1.0 / 125, "1/125 s"), (1.0 / 60, "1/60 s"),
        (1.0 / 8, "1/8 s"), (1.0 / 4, "1/4 s"),
        (0.3, "0.3 s"), (0.5, "0.5 s"), (0.8, "0.8 s"),
        (1, "1 s"), (1.3, "1.3 s"), (2, "2 s"), (2.5, "2.5 s"), (30, "30 s")
    ]

    @Test(arguments: ExposureFormatterTests.exposureTimes)
    func formatsExposureTimes(value: Double, expected: String) {
        #expect(ExposureFormatter.exposureTime(value, locale: Self.english) == expected)
    }

    @Test
    func fractionDenominatorIsRoundedNotTruncated() {
        #expect(ExposureFormatter.exposureTime(0.008000000000000001, locale: Self.english) == "1/125 s")
        #expect(ExposureFormatter.exposureTime(1 / 124.99999999, locale: Self.english) == "1/125 s")
    }

    @Test
    func invalidExposureTimeIsEmpty() {
        #expect(ExposureFormatter.exposureTime(0, locale: Self.english).isEmpty)
        #expect(ExposureFormatter.exposureTime(-1, locale: Self.english).isEmpty)
    }

    static let isoValues: [(Double, String)] = [
        (50, "ISO 50"), (100, "ISO 100"), (1600, "ISO 1600"), (12800, "ISO 12800")
    ]

    @Test(arguments: ExposureFormatterTests.isoValues)
    func formatsISO(value: Double, expected: String) {
        #expect(ExposureFormatter.iso(value, locale: Self.english) == expected)
    }

    static let evValues: [(Double, String)] = [
        (14.966, "EV 15.0"), (14.94, "EV 14.9"), (0, "EV 0.0"), (-2.34, "EV -2.3")
    ]

    @Test(arguments: ExposureFormatterTests.evValues)
    func formatsEV(value: Double, expected: String) {
        #expect(ExposureFormatter.ev(value, locale: Self.english) == expected)
    }

    @Test
    func usesTheLocaleDecimalSeparator() {
        #expect(ExposureFormatter.aperture(5.6, locale: Self.spanish) == "f/5,6")
        #expect(ExposureFormatter.exposureTime(1.3, locale: Self.spanish) == "1,3 s")
        #expect(ExposureFormatter.ev(14.9, locale: Self.spanish) == "EV 14,9")
    }

    @Test
    func isoHasNoGroupingSeparator() {
        #expect(ExposureFormatter.iso(12800, locale: Self.spanish) == "ISO 12800")
    }

    nonisolated static let equivalentPairs: [(Double, Double, String)] = [
        (5.6, 1.0 / 500, "f/5.6 · 1/500"), (2.8, 1.0 / 2000, "f/2.8 · 1/2000"),
        (16, 1.0 / 4, "f/16 · 1/4"), (11, 0.5, "f/11 · 0.5 s"),
        (8, 2, "f/8 · 2 s"), (22, 1.3, "f/22 · 1.3 s")
    ]

    @Test(arguments: ExposureFormatterTests.equivalentPairs)
    func formatsEquivalentPairsWithoutUnitForFractions(aperture: Double, time: Double, expected: String) {
        #expect(ExposureFormatter.equivalent(aperture: aperture, exposureTime: time, locale: Self.english) == expected)
    }

    @Test
    func equivalentPairUsesTheLocale() {
        #expect(ExposureFormatter.equivalent(aperture: 5.6, exposureTime: 1.3, locale: Self.spanish) == "f/5,6 · 1,3 s")
    }

    @Test
    func equivalentPairWithInvalidTimeIsEmpty() {
        #expect(ExposureFormatter.equivalent(aperture: 5.6, exposureTime: 0, locale: Self.english).isEmpty)
    }
}
