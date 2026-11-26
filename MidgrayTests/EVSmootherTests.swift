//
//  EVSmootherTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Testing
@testable import Midgray

struct EVSmootherTests {
    @Test
    func firstReadingIsReturnedAsIs() throws {
        var smoother = try #require(EVSmoother())
        #expect(smoother.value == nil)
        #expect(smoother.add(7.5) == 7.5)
        #expect(smoother.value == 7.5)
    }

    @Test
    func halfSmoothingMovesHalfWayToTheNewReading() throws {
        var smoother = try #require(EVSmoother(smoothing: 0.5))
        smoother.add(10)
        #expect(smoother.add(12) == 11)
        #expect(smoother.add(13) == 12)
    }

    @Test
    func fullSmoothingFollowsTheReadingExactly() throws {
        var smoother = try #require(EVSmoother(smoothing: 1))
        smoother.add(10)
        #expect(smoother.add(3) == 3)
    }

    static let smoothingValues: [Double] = [0.05, 0.2, 0.5, 0.9]

    @Test(arguments: EVSmootherTests.smoothingValues)
    func constantInputConvergesToTheInput(smoothing: Double) throws {
        var smoother = try #require(EVSmoother(smoothing: smoothing))
        smoother.add(0)
        for _ in 0..<500 { smoother.add(10) }
        let value = try #require(smoother.value)
        #expect(abs(value - 10) < 0.001)
    }

    @Test(arguments: EVSmootherTests.smoothingValues)
    func smoothedValueStaysBetweenPreviousAndNewReading(smoothing: Double) throws {
        var smoother = try #require(EVSmoother(smoothing: smoothing))
        smoother.add(4)
        let added = smoother.add(9)
        let result = try #require(added)
        #expect(result > 4 && result <= 9)
    }

    static let nonFiniteValues: [Double] = [.nan, .infinity, -.infinity]

    @Test(arguments: EVSmootherTests.nonFiniteValues)
    func nonFiniteReadingsAreIgnored(reading: Double) throws {
        var smoother = try #require(EVSmoother())
        smoother.add(8)
        #expect(smoother.add(reading) == 8)
        #expect(smoother.value == 8)
    }

    @Test(arguments: EVSmootherTests.nonFiniteValues)
    func nonFiniteFirstReadingLeavesNoValue(reading: Double) throws {
        var smoother = try #require(EVSmoother())
        #expect(smoother.add(reading) == nil)
        #expect(smoother.value == nil)
    }

    @Test
    func resetForgetsThePreviousValue() throws {
        var smoother = try #require(EVSmoother(smoothing: 0.5))
        smoother.add(10)
        smoother.reset()
        #expect(smoother.value == nil)
        #expect(smoother.add(2) == 2)
    }

    static let invalidSmoothing: [Double] = [0, -0.1, 1.5, .nan, .infinity]

    @Test(arguments: EVSmootherTests.invalidSmoothing)
    func invalidSmoothingIsRejected(smoothing: Double) {
        #expect(EVSmoother(smoothing: smoothing) == nil)
    }
}
