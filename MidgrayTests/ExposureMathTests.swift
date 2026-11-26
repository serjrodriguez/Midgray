//
//  ExposureMathTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 19/11/26.
//

import Testing
@testable import Midgray

struct ExposureMathTests {
    struct Sample: Sendable {
        let aperture: Double
        let exposureTime: Double
        let iso: Double
        let expected: Double
    }

    static let samples: [Sample] = [
        Sample(aperture: 16, exposureTime: 1.0 / 125, iso: 100, expected: 14.966),
        Sample(aperture: 8, exposureTime: 1.0 / 250, iso: 100, expected: 13.966),
        Sample(aperture: 2.8, exposureTime: 1.0 / 60, iso: 100, expected: 8.878),
        Sample(aperture: 5.6, exposureTime: 1.0 / 500, iso: 200, expected: 12.937)
    ]

    @Test(arguments: ExposureMathTests.samples)
    func ev100MatchesKnownValues(sample: Sample) throws {
        let result = try #require(
            ExposureMath.ev100(
                aperture: sample.aperture,
                exposureTime: sample.exposureTime,
                iso: sample.iso
            )
        )
        #expect(abs(result - sample.expected) < 0.01)
    }

    @Test(arguments: [
        (0.0, 0.01, 100.0),
        (-1.0, 0.01, 100.0),
        (5.6, 0.0, 100.0),
        (5.6, -0.01, 100.0),
        (5.6, 0.01, 0.0),
        (5.6, 0.01, -100.0)
    ])
    func ev100RejectsNonPositiveInputs(aperture: Double, exposureTime: Double, iso: Double) {
        #expect(ExposureMath.ev100(aperture: aperture, exposureTime: exposureTime, iso: iso) == nil)
    }

    struct Exposure: Sendable {
        let aperture: Double
        let exposureTime: Double
        let iso: Double
    }

    static let roundTripExposures: [Exposure] = {
        let apertures: [Double] = [1.4, 2.8, 5.6, 11, 22]
        let exposureTimes: [Double] = [1.0 / 1000, 1.0 / 125, 1.0 / 15, 1]
        let isoValues: [Double] = [100, 400, 1600]
        return apertures.flatMap { aperture in
            exposureTimes.flatMap { exposureTime in
                isoValues.map { iso in
                    Exposure(aperture: aperture, exposureTime: exposureTime, iso: iso)
                }
            }
        }
    }()

    static func isClose(_ result: Double, to expected: Double, tolerance: Double = 0.0001) -> Bool {
        abs(result - expected) / expected < tolerance
    }

    @Test(arguments: ExposureMathTests.roundTripExposures)
    func exposureTimeRoundTrips(exposure: Exposure) throws {
        let ev = try #require(
            ExposureMath.ev100(aperture: exposure.aperture, exposureTime: exposure.exposureTime, iso: exposure.iso)
        )
        let result = try #require(
            ExposureMath.exposureTime(ev100: ev, aperture: exposure.aperture, iso: exposure.iso)
        )
        #expect(Self.isClose(result, to: exposure.exposureTime))
    }

    @Test(arguments: ExposureMathTests.roundTripExposures)
    func apertureRoundTrips(exposure: Exposure) throws {
        let ev = try #require(
            ExposureMath.ev100(aperture: exposure.aperture, exposureTime: exposure.exposureTime, iso: exposure.iso)
        )
        let result = try #require(
            ExposureMath.aperture(ev100: ev, exposureTime: exposure.exposureTime, iso: exposure.iso)
        )
        #expect(Self.isClose(result, to: exposure.aperture))
    }

    @Test(arguments: ExposureMathTests.roundTripExposures)
    func isoRoundTrips(exposure: Exposure) throws {
        let ev = try #require(
            ExposureMath.ev100(aperture: exposure.aperture, exposureTime: exposure.exposureTime, iso: exposure.iso)
        )
        let result = try #require(
            ExposureMath.iso(ev100: ev, aperture: exposure.aperture, exposureTime: exposure.exposureTime)
        )
        #expect(Self.isClose(result, to: exposure.iso))
    }

    @Test
    func sunnySixteenGivesOneOneHundredTwentyFifth() throws {
        let result = try #require(ExposureMath.exposureTime(ev100: 14.966, aperture: 16, iso: 100))
        #expect(Self.isClose(result, to: 1.0 / 125, tolerance: 0.01))
    }

    @Test
    func negativeEVIsAccepted() {
        #expect(ExposureMath.exposureTime(ev100: -4, aperture: 1.4, iso: 800) != nil)
    }

    static let nonFiniteValues: [Double] = [.infinity, -.infinity, .nan]

    @Test(arguments: ExposureMathTests.nonFiniteValues)
    func derivedValuesRejectNonFiniteEV(ev: Double) {
        #expect(ExposureMath.exposureTime(ev100: ev, aperture: 5.6, iso: 100) == nil)
        #expect(ExposureMath.aperture(ev100: ev, exposureTime: 0.01, iso: 100) == nil)
        #expect(ExposureMath.iso(ev100: ev, aperture: 5.6, exposureTime: 0.01) == nil)
    }

    @Test(arguments: [0.0, -1.0])
    func derivedValuesRejectNonPositiveInputs(value: Double) {
        #expect(ExposureMath.exposureTime(ev100: 10, aperture: value, iso: 100) == nil)
        #expect(ExposureMath.exposureTime(ev100: 10, aperture: 5.6, iso: value) == nil)
        #expect(ExposureMath.aperture(ev100: 10, exposureTime: value, iso: 100) == nil)
        #expect(ExposureMath.aperture(ev100: 10, exposureTime: 0.01, iso: value) == nil)
        #expect(ExposureMath.iso(ev100: 10, aperture: value, exposureTime: 0.01) == nil)
        #expect(ExposureMath.iso(ev100: 10, aperture: 5.6, exposureTime: value) == nil)
    }
}
