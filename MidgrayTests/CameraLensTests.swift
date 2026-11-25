//
//  CameraLensTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
import Foundation
@testable import Midgray

struct CameraLensTests {
    nonisolated static let factors: [(Double, Double, Double)] = [
        (120, 69, 0.5),
        (69, 69, 1),
        (15.2, 69, 5)
    ]

    @Test(arguments: CameraLensTests.factors)
    func zoomFactorIsDerivedFromTheFieldOfView(fieldOfView: Double, reference: Double, expected: Double) throws {
        let factor = try #require(CameraLens.zoomFactor(fieldOfView: fieldOfView, referenceFieldOfView: reference))
        #expect(factor == expected)
    }

    @Test(arguments: [0.0, -10, 180, 200, Double.nan, Double.infinity])
    func invalidFieldsOfViewAreRejected(value: Double) {
        #expect(CameraLens.zoomFactor(fieldOfView: value, referenceFieldOfView: 69) == nil)
        #expect(CameraLens.zoomFactor(fieldOfView: 69, referenceFieldOfView: value) == nil)
    }

    @Test(arguments: [(0.5, "0.5×"), (1.0, "1×"), (3.0, "3×"), (2.5, "2.5×")])
    func labelDropsUnneededDecimals(factor: Double, expected: String) {
        let lens = CameraLens(id: "x", kind: .wide, zoomFactor: factor)
        #expect(lens.zoomLabel(locale: Locale(identifier: "en_US")) == expected)
    }
}
