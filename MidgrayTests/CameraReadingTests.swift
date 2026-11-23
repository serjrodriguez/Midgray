//
//  CameraReadingTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Testing
@testable import Midgray

struct CameraReadingTests {
    static let sunnySixteenEV: Double = ExposureMath.ev100(aperture: 16, exposureTime: 1.0 / 125, iso: 100) ?? 0

    static func sunnySixteen(offset: Double) -> CameraReading {
        CameraReading(aperture: 16, exposureTime: 1.0 / 125, iso: 100, exposureTargetOffset: offset)
    }

    @Test
    func zeroOffsetKeepsTheSettingsEV() throws {
        let ev = try #require(Self.sunnySixteen(offset: 0).ev100)
        #expect(abs(ev - Self.sunnySixteenEV) < 1e-9)
    }

    static let offsets: [Double] = [-2, -1, -0.5, 0.5, 1, 2]

    @Test(arguments: CameraReadingTests.offsets)
    func offsetIsAddedToTheSettingsEV(offset: Double) throws {
        let ev = try #require(Self.sunnySixteen(offset: offset).ev100)
        #expect(abs(ev - (Self.sunnySixteenEV + offset)) < 1e-9)
    }

    static let invalidReadings: [CameraReading] = [
        CameraReading(aperture: 0, exposureTime: 0.01, iso: 100, exposureTargetOffset: 0),
        CameraReading(aperture: 1.8, exposureTime: 0, iso: 100, exposureTargetOffset: 0),
        CameraReading(aperture: 1.8, exposureTime: 0.01, iso: 0, exposureTargetOffset: 0),
        CameraReading(aperture: 1.8, exposureTime: 0.01, iso: 100, exposureTargetOffset: .nan),
        CameraReading(aperture: 1.8, exposureTime: 0.01, iso: 100, exposureTargetOffset: .infinity)
    ]

    @Test(arguments: CameraReadingTests.invalidReadings)
    func invalidReadingsHaveNoEV(reading: CameraReading) {
        #expect(reading.ev100 == nil)
    }
}
