//
//  ExposureScaleTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 19/11/26.
//

import Testing
@testable import Midgray

struct ExposureScaleTests {
    static let apertureCases: [(Double, Double)] = [
        (5.657, 5.6), (5.9, 5.6), (6.0, 6.3), (0.5, 1.0), (100.0, 32.0)
    ]

    static let shutterCases: [(Double, Double)] = [
        (1.0 / 512, 1.0 / 500), (1.0 / 130, 1.0 / 125), (0.9, 1.0),
        (1.0 / 100000, 1.0 / 4000), (600.0, 30.0)
    ]

    static let isoCases: [(Double, Double)] = [
        (56.8, 64.0), (56.0, 50.0), (110.0, 100.0), (1.0, 50.0), (100000.0, 12800.0)
    ]

    @Test(arguments: ExposureScaleTests.apertureCases)
    func nearestAperture(value: Double, expected: Double) throws {
        let result = try #require(ExposureScale.nearest(to: value, in: ExposureScale.apertures))
        #expect(result == expected)
    }

    @Test(arguments: ExposureScaleTests.shutterCases)
    func nearestShutterSpeed(value: Double, expected: Double) throws {
        let result = try #require(ExposureScale.nearest(to: value, in: ExposureScale.shutterSpeeds))
        #expect(result == expected)
    }

    @Test(arguments: ExposureScaleTests.isoCases)
    func nearestISO(value: Double, expected: Double) throws {
        let result = try #require(ExposureScale.nearest(to: value, in: ExposureScale.isoValues))
        #expect(result == expected)
    }

    @Test(arguments: [0.0, -1.0, -0.001])
    func nearestRejectsNonPositiveValues(value: Double) {
        #expect(ExposureScale.nearest(to: value, in: ExposureScale.apertures) == nil)
    }

    @Test
    func nearestReturnsNilForEmptyScale() {
        #expect(ExposureScale.nearest(to: 5.6, in: []) == nil)
    }

    @Test(arguments: [ExposureScale.apertures, ExposureScale.shutterSpeeds, ExposureScale.isoValues])
    func scalesAreStrictlyAscending(scale: [Double]) {
        #expect(zip(scale, scale.dropFirst()).allSatisfy { $0 < $1 })
    }
}
