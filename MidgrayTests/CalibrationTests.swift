//
//  CalibrationTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

struct CalibrationTests {
    nonisolated static let normalizations: [(Double, Double)] = [
        (0, 0),
        (0.04, 0),
        (0.06, 0.1),
        (0.3, 0.3),
        (-0.3, -0.3),
        (1.96, 2),
        (3, 2),
        (-3, -2),
        (.nan, 0),
        (.infinity, 0),
        (-.infinity, 0)
    ]

    @Test(arguments: CalibrationTests.normalizations)
    func normalizedRoundsToTenthsAndClamps(input: Double, expected: Double) {
        #expect(Calibration.normalized(input) == expected)
    }

    nonisolated static let steps: [(Double, Int, Double)] = [
        (0, 3, 0.3),
        (0.3, -3, 0),
        (0, -1, -0.1),
        (2, 1, 2),
        (-2, -1, -2),
        (1.9, 5, 2)
    ]

    @Test(arguments: CalibrationTests.steps)
    func steppedMovesInTenthsWithinTheRange(start: Double, steps: Int, expected: Double) {
        #expect(Calibration.stepped(start, by: steps) == expected)
    }

    @Test
    func tenSuccessiveStepsMakeOneEVWithoutDrift() {
        var value = 0.0
        for _ in 0..<10 { value = Calibration.stepped(value, by: 1) }
        #expect(value == 1)
    }
}
