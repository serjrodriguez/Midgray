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
}
