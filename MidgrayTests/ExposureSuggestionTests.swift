//
//  ExposureSuggestionTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 20/11/26.
//

import Testing
@testable import Midgray

struct ExposureSuggestionTests {
    static let sunnySixteenEV: Double = ExposureMath.ev100(aperture: 16, exposureTime: 1.0 / 125, iso: 100) ?? 0

    @Test
    func aperturePriorityGivesSunnySixteenTime() throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 100, priority: .aperture(16))
        )
        #expect(result.aperture == 16)
        #expect(result.exposureTime == 1.0 / 125)
        #expect(result.iso == 100)
        #expect(abs(result.evError) < 0.001)
    }

    @Test
    func shutterPriorityGivesSunnySixteenAperture() throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 100, priority: .shutter(1.0 / 125))
        )
        #expect(result.aperture == 16)
        #expect(result.exposureTime == 1.0 / 125)
        #expect(abs(result.evError) < 0.001)
    }

    @Test
    func userValuesAreRoundedToTheScale() throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 110, priority: .aperture(16.2))
        )
        #expect(result.aperture == 16)
        #expect(result.iso == 100)
    }

    static let evs: [Double] = [-2, 3, 8, 12.3, 14.966]
    static let apertureSettings: [Double] = [1.4, 2.8, 5.6, 11]

    @Test(arguments: ExposureSuggestionTests.evs, ExposureSuggestionTests.apertureSettings)
    func evErrorIsMeasuredMinusAchieved(ev: Double, aperture: Double) throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: ev, baseISO: 200, priority: .aperture(aperture))
        )
        let achieved = try #require(
            ExposureMath.ev100(aperture: result.aperture, exposureTime: result.exposureTime, iso: result.iso)
        )
        #expect(abs(result.evError - (ev - achieved)) < 1e-9)

        let shortest = ExposureScale.shutterSpeeds.first ?? 0
        let longest = ExposureScale.shutterSpeeds.last ?? 0
        if result.exposureTime > shortest && result.exposureTime < longest {
            #expect(abs(result.evError) < 0.25)
        }
    }

    @Test
    func evErrorIsPositiveWhenTheTimeIsClampedTooLong() throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: 20, baseISO: 100, priority: .aperture(1.4))
        )
        #expect(result.exposureTime == 1.0 / 4000)
        #expect(result.evError > 1)
    }

    @Test
    func invalidInputsReturnNil() {
        let ev = Self.sunnySixteenEV
        #expect(ExposureSuggestion.suggestion(ev100: ev, baseISO: 0, priority: .aperture(16)) == nil)
        #expect(ExposureSuggestion.suggestion(ev100: ev, baseISO: 100, priority: .aperture(0)) == nil)
        #expect(ExposureSuggestion.suggestion(ev100: ev, baseISO: 100, priority: .shutter(-1)) == nil)
        #expect(ExposureSuggestion.suggestion(ev100: .nan, baseISO: 100, priority: .aperture(16)) == nil)
        #expect(ExposureSuggestion.suggestion(ev100: .infinity, baseISO: 100, priority: .shutter(0.01)) == nil)
    }

    static let sunnySixteenPairs: [(Double, Double)] = [
        (16, 1.0 / 125), (8, 1.0 / 500), (11, 1.0 / 250), (22, 1.0 / 60)
    ]

    @Test(arguments: ExposureSuggestionTests.sunnySixteenPairs)
    func equivalentsContainSunnySixteenPairs(aperture: Double, exposureTime: Double) {
        let list = ExposureSuggestion.equivalents(ev100: Self.sunnySixteenEV, iso: 100)
        #expect(list.contains { $0.aperture == aperture && $0.exposureTime == exposureTime })
    }

    @Test
    func equivalentsAreAscendingByApertureAndShareTheRoundedISO() {
        let list = ExposureSuggestion.equivalents(ev100: Self.sunnySixteenEV, iso: 110)
        #expect(zip(list, list.dropFirst()).allSatisfy { $0.aperture < $1.aperture })
        #expect(list.allSatisfy { $0.iso == 100 && abs($0.evError) <= 0.5 })
    }

    @Test
    func equivalentsDropCombinationsOutsideTheShutterRange() {
        let dark = ExposureSuggestion.equivalents(ev100: -2, iso: 100)
        #expect(dark.count < ExposureScale.apertures.count)
        #expect(!dark.contains { $0.aperture == 32 })

        let bright = ExposureSuggestion.equivalents(ev100: 20, iso: 100)
        #expect(!bright.contains { $0.aperture == 1.4 })
        #expect(bright.contains { $0.aperture == 32 })
    }

    @Test
    func equivalentsAreEmptyForInvalidISO() {
        #expect(ExposureSuggestion.equivalents(ev100: 10, iso: 0).isEmpty)
    }
}
