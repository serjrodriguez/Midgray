//
//  ExposureScaleTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 19/11/26.
//

import Foundation
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

    nonisolated static let steps: [(Double, Int, Double)] = [
        (5.6, 1, 6.3), (5.6, -1, 5.0), (5.6, 0, 5.6), (5.6, 3, 8), (5.6, -3, 4.0),
        (1.0, -1, 1.0), (32, 1, 32), (5.6, 100, 32), (5.6, -100, 1.0), (5.7, 1, 6.3)
    ]

    @Test(arguments: ExposureScaleTests.steps)
    func stepMovesAlongTheApertureScaleAndClampsAtTheEnds(value: Double, offset: Int, expected: Double) {
        #expect(ExposureScale.step(value, by: offset, in: ExposureScale.apertures) == expected)
    }

    @Test
    func stepWorksOnTheShutterAndISOScales() {
        #expect(ExposureScale.step(1.0 / 125, by: 1, in: ExposureScale.shutterSpeeds) == 1.0 / 100)
        #expect(ExposureScale.step(100, by: -1, in: ExposureScale.isoValues) == 80)
        #expect(ExposureScale.step(100, by: 2, in: ExposureScale.isoValues) == 160)
    }

    @Test
    func stepRejectsInvalidInputs() {
        #expect(ExposureScale.step(0, by: 1, in: ExposureScale.apertures) == nil)
        #expect(ExposureScale.step(-3, by: 1, in: ExposureScale.apertures) == nil)
        #expect(ExposureScale.step(5.6, by: 1, in: []) == nil)
    }

    @Test
    func everyLabelHasAnExactStop() {
        #expect(ExposureScale.apertureStops.map(\.nominal) == ExposureScale.apertures)
        #expect(ExposureScale.shutterStops.map(\.nominal) == ExposureScale.shutterSpeeds)
        #expect(ExposureScale.isoStops.map(\.nominal) == ExposureScale.isoValues)
    }

    @Test(arguments: [ExposureScale.apertureStops, ExposureScale.shutterStops, ExposureScale.isoStops])
    func exactStopsStayCloseToTheirLabels(stops: [ExposureStop]) {
        #expect(stops.allSatisfy { abs(log2($0.nominal / $0.exact)) < 0.1 })
    }
}
