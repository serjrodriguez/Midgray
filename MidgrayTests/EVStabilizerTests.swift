//
//  EVStabilizerTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

struct EVStabilizerTests {
    @Test
    func firstReadingIsReturnedAsIs() throws {
        var stabilizer = try #require(EVStabilizer(threshold: 0.2))
        #expect(stabilizer.add(9.3) == 9.3)
    }

    @Test
    func smallChangesKeepTheCurrentValue() throws {
        var stabilizer = try #require(EVStabilizer(threshold: 0.2))
        stabilizer.add(10)

        #expect(stabilizer.add(10.1) == 10)
        #expect(stabilizer.add(9.85) == 10)
        #expect(stabilizer.value == 10)
    }

    @Test
    func changesAtOrBeyondTheThresholdMoveTheValue() throws {
        var stabilizer = try #require(EVStabilizer(threshold: 0.2))
        stabilizer.add(10)

        #expect(stabilizer.add(10.25) == 10.25)
        #expect(stabilizer.add(10.1) == 10.25)
        #expect(stabilizer.add(9.0) == 9.0)
    }

    @Test
    func noiseAroundABoundaryDoesNotFlicker() throws {
        var stabilizer = try #require(EVStabilizer(threshold: 0.15))
        stabilizer.add(10)

        let noisy: [Double] = [10.05, 9.95, 10.1, 9.9, 10.07, 9.93]
        let outputs = noisy.compactMap { stabilizer.add($0) }
        #expect(Set(outputs) == [10])
    }

    @Test(arguments: [Double.nan, .infinity, -.infinity])
    func nonFiniteReadingsAreIgnored(reading: Double) throws {
        var stabilizer = try #require(EVStabilizer())
        #expect(stabilizer.add(reading) == nil)

        stabilizer.add(8)
        #expect(stabilizer.add(reading) == 8)
    }

    @Test
    func resetForgetsTheCurrentValue() throws {
        var stabilizer = try #require(EVStabilizer())
        stabilizer.add(8)
        stabilizer.reset()

        #expect(stabilizer.value == nil)
        #expect(stabilizer.add(12) == 12)
    }

    @Test(arguments: [-0.1, Double.nan, .infinity])
    func invalidThresholdsAreRejected(threshold: Double) {
        #expect(EVStabilizer(threshold: threshold) == nil)
    }

    @Test
    func zeroThresholdFollowsEveryChange() throws {
        var stabilizer = try #require(EVStabilizer(threshold: 0))
        stabilizer.add(10)
        #expect(stabilizer.add(10.01) == 10.01)
    }
}
