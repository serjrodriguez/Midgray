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
        #expect(abs(result.evError) < 0.05)
    }

    @Test
    func shutterPriorityGivesSunnySixteenAperture() throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 100, priority: .shutter(1.0 / 125))
        )
        #expect(result.aperture == 16)
        #expect(result.exposureTime == 1.0 / 125)
        #expect(abs(result.evError) < 0.05)
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
            exactEV(aperture: result.aperture, exposureTime: result.exposureTime, iso: result.iso)
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

    nonisolated static let sweptEVs: [Double] = (0...1800).map { Double($0) / 100 }

    @Test
    func consecutiveEquivalentsAlwaysDifferByOneShutterStep() {
        let irregular = Self.sweptEVs.filter { ev in
            let list = ExposureSuggestion.equivalents(ev100: ev, iso: 100)
            let indices = list.compactMap { ExposureScale.shutterSpeeds.firstIndex(of: $0.exposureTime) }
            return zip(indices, indices.dropFirst()).contains { $1 - $0 != 1 }
        }
        #expect(irregular.isEmpty)
    }

    @Test
    func equivalentsStayWithinHalfAThirdStop() {
        let tooFar = Self.sweptEVs.filter { ev in
            ExposureSuggestion.equivalents(ev100: ev, iso: 100).contains { abs($0.evError) > 1.0 / 6 + 1e-6 }
        }
        #expect(tooFar.isEmpty)
    }

    nonisolated static let pairsNearAHalfStep: [(Double, Double)] = [
        (5.0, 1.0 / 1250), (5.6, 1.0 / 1000), (6.3, 1.0 / 800)
    ]

    @Test(arguments: ExposureSuggestionTests.pairsNearAHalfStep)
    func neighbouringAperturesGetDifferentTimes(aperture: Double, exposureTime: Double) throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: 15.1, baseISO: 100, priority: .aperture(aperture))
        )
        #expect(result.exposureTime == exposureTime)
    }

    @Test
    func equivalentsAreEmptyForInvalidISO() {
        #expect(ExposureSuggestion.equivalents(ev100: 10, iso: 0).isEmpty)
    }

    @Test
    func isoPriorityGivesSunnySixteenISO() throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 800, priority: .iso(aperture: 16, shutter: 1.0 / 125))
        )
        #expect(result.aperture == 16)
        #expect(result.exposureTime == 1.0 / 125)
        #expect(result.iso == 100)
        #expect(abs(result.evError) < 0.05)
    }

    @Test
    func isoPriorityIgnoresTheBaseISO() throws {
        let low = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 50, priority: .iso(aperture: 8, shutter: 1.0 / 1000))
        )
        let invalid = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: -1, priority: .iso(aperture: 8, shutter: 1.0 / 1000))
        )
        #expect(low == invalid)
        #expect(low.iso == 200)
    }

    @Test
    func isoPriorityRoundsAperturesAndTimesToTheScale() throws {
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 100, priority: .iso(aperture: 16.2, shutter: 0.0081))
        )
        #expect(result.aperture == 16)
        #expect(result.exposureTime == 1.0 / 125)
    }

    nonisolated static let isoTriples: [(Double, Double, Double)] = [
        (1.4, 1.0 / 500, 50), (2.8, 1.0 / 125, 200), (5.6, 1.0 / 60, 400),
        (8, 1.0 / 250, 1600), (11, 1.0 / 30, 125), (16, 1.0 / 15, 3200)
    ]

    @Test(arguments: ExposureSuggestionTests.isoTriples)
    func isoPriorityRecoversTheISOUsedToComputeTheEV(aperture: Double, time: Double, iso: Double) throws {
        let ev = try #require(exactEV(aperture: aperture, exposureTime: time, iso: iso))
        let result = try #require(
            ExposureSuggestion.suggestion(ev100: ev, baseISO: 100, priority: .iso(aperture: aperture, shutter: time))
        )
        #expect(result.iso == iso)
        #expect(abs(result.evError) < 0.001)
    }

    @Test
    func isoPriorityClampsToTheScaleAndReportsTheError() throws {
        let tooBright = try #require(
            ExposureSuggestion.suggestion(ev100: Self.sunnySixteenEV, baseISO: 100, priority: .iso(aperture: 1, shutter: 1.0 / 30))
        )
        #expect(tooBright.iso == 50)
        #expect(tooBright.evError > 1)

        let tooDark = try #require(
            ExposureSuggestion.suggestion(ev100: 2, baseISO: 100, priority: .iso(aperture: 32, shutter: 1.0 / 4000))
        )
        #expect(tooDark.iso == 12800)
        #expect(tooDark.evError < -1)
    }

    @Test
    func isoPriorityRejectsInvalidInputs() {
        #expect(ExposureSuggestion.suggestion(ev100: .nan, baseISO: 100, priority: .iso(aperture: 8, shutter: 0.01)) == nil)
        #expect(ExposureSuggestion.suggestion(ev100: 10, baseISO: 100, priority: .iso(aperture: 0, shutter: 0.01)) == nil)
        #expect(ExposureSuggestion.suggestion(ev100: 10, baseISO: 100, priority: .iso(aperture: 8, shutter: -1)) == nil)
    }

    private func exactEV(aperture: Double, exposureTime: Double, iso: Double) -> Double? {
        guard let aperture = ExposureScale.stop(labelled: aperture, in: ExposureScale.apertureStops),
              let shutter = ExposureScale.stop(labelled: exposureTime, in: ExposureScale.shutterStops),
              let sensitivity = ExposureScale.stop(labelled: iso, in: ExposureScale.isoStops)
        else { return nil }

        return ExposureMath.ev100(aperture: aperture.exact, exposureTime: shutter.exact, iso: sensitivity.exact)
    }
}
