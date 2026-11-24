//
//  MeterViewModelTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

@MainActor
struct MeterViewModelTests {
    nonisolated static let base: Double = ExposureMath.ev100(aperture: 16, exposureTime: 1.0 / 125, iso: 100) ?? 0

    nonisolated static func reading(offset: Double) -> CameraReading {
        CameraReading(aperture: 16, exposureTime: 1.0 / 125, iso: 100, exposureTargetOffset: offset)
    }

    nonisolated static let invalidReading = CameraReading(aperture: 16, exposureTime: 1.0 / 125, iso: 100, exposureTargetOffset: .nan)

    func makeViewModel(_ readings: [CameraReading],
                       smoothing: Double = 0.5,
                       mode: ExposureMode = .auto,
                       aperture: Double = 5.6,
                       shutterSpeed: Double = 1.0 / 125,
                       baseISO: Double = 100) throws -> MeterViewModel {
        let smoother = try #require(EVSmoother(smoothing: smoothing))
        return MeterViewModel(sensor: FakeLightSensor(scriptedReadings: readings),
                              smoother: smoother,
                              mode: mode,
                              aperture: aperture,
                              shutterSpeed: shutterSpeed,
                              baseISO: baseISO)
    }

    func currentReadout(_ viewModel: MeterViewModel) -> MeterReadout? {
        switch viewModel.state {
        case .idle: return nil
        case .measuring(let readout), .outOfRange(let readout): return readout
        }
    }

    func waitUntil(_ condition: () -> Bool) async -> Bool {
        for _ in 0..<1000 {
            if condition() { return true }
            await Task.yield()
        }
        return condition()
    }

    @Test
    func startsIdle() throws {
        let viewModel = try makeViewModel([])
        #expect(viewModel.state == .idle)
    }

    @Test
    func publishesTheSmoothedEV() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0), Self.reading(offset: 2)])
        let expected = Self.base + 1

        viewModel.start()

        let reached = await waitUntil { abs((currentReadout(viewModel)?.ev ?? .nan) - expected) < 1e-9 }
        #expect(reached)
    }

    @Test
    func skipsInvalidReadingsWithoutStopping() async throws {
        let viewModel = try makeViewModel([
            Self.reading(offset: 0),
            Self.invalidReading,
            Self.reading(offset: 2)
        ])
        let expected = Self.base + 1

        viewModel.start()

        let reached = await waitUntil { abs((currentReadout(viewModel)?.ev ?? .nan) - expected) < 1e-9 }
        #expect(reached)
    }

    @Test
    func stopReturnsToIdle() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)])

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        viewModel.stop()
        #expect(viewModel.state == .idle)
    }

    @Test
    func stopResetsTheSmoother() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 2)])

        viewModel.start()
        let first = await waitUntil { currentReadout(viewModel) != nil }
        #expect(first)
        viewModel.stop()

        viewModel.start()
        let reached = await waitUntil { abs((currentReadout(viewModel)?.ev ?? .nan) - (Self.base + 2)) < 1e-9 }
        #expect(reached)
    }

    @Test
    func aperturePriorityGivesSunnySixteenTime() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .aperture, aperture: 16)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(suggestion.aperture == 16)
        #expect(suggestion.iso == 100)
        #expect(abs(suggestion.exposureTime - 1.0 / 125) < 1e-9)
    }

    @Test
    func changingThePriorityUpdatesTheSuggestionWithoutNewReadings() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .aperture, aperture: 16)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        viewModel.mode = .shutter
        viewModel.shutterSpeed = 1.0 / 125

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(suggestion.exposureTime == 1.0 / 125)
        #expect(suggestion.aperture == 16)
    }

    @Test
    func changingTheBaseISOUpdatesTheSuggestion() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .aperture, aperture: 16)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        viewModel.baseISO = 200

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(suggestion.iso == 200)
        #expect(suggestion.exposureTime < 1.0 / 125)
    }

    @Test
    func equivalentsMatchTheMeteredLight() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)])

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        let equivalents = try #require(currentReadout(viewModel)?.equivalents)
        #expect(!equivalents.isEmpty)
        #expect(equivalents.allSatisfy { $0.iso == 100 && abs($0.evError) <= 0.5 })
    }

    @Test
    func startsWithoutCompensation() throws {
        let viewModel = try makeViewModel([])
        #expect(viewModel.compensation == 0)
    }

    nonisolated static let steppedValues: [(Double, Double)] = [
        (0.1, 0), (0.2, 1.0 / 3), (0.5, 2.0 / 3), (1, 1), (-0.4, -1.0 / 3), (-1.7, -5.0 / 3)
    ]

    @Test(arguments: MeterViewModelTests.steppedValues)
    func compensationSnapsToThirdsOfAStop(value: Double, expected: Double) throws {
        let viewModel = try makeViewModel([])
        viewModel.setCompensation(value)
        #expect(abs(viewModel.compensation - expected) < 1e-9)
    }

    nonisolated static let outOfRangeValues: [(Double, Double)] = [(5, 3), (3.4, 3), (-4, -3), (-100, -3)]

    @Test(arguments: MeterViewModelTests.outOfRangeValues)
    func compensationIsClampedToTheRange(value: Double, expected: Double) throws {
        let viewModel = try makeViewModel([])
        viewModel.setCompensation(value)
        #expect(viewModel.compensation == expected)
    }

    @Test
    func nonFiniteCompensationIsIgnored() throws {
        let viewModel = try makeViewModel([])
        viewModel.setCompensation(1)
        viewModel.setCompensation(.nan)
        viewModel.setCompensation(.infinity)
        #expect(viewModel.compensation == 1)
    }

    @Test
    func positiveCompensationLengthensTheExposure() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .aperture, aperture: 16)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        viewModel.setCompensation(1)

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(abs(suggestion.exposureTime - 1.0 / 60) < 1e-9)
        #expect(abs((currentReadout(viewModel)?.compensatedEV ?? .nan) - (Self.base - 1)) < 1e-9)
    }

    @Test
    func compensationDoesNotChangeTheMeasuredEV() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)])

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        viewModel.setCompensation(-2)
        #expect(abs((currentReadout(viewModel)?.ev ?? .nan) - Self.base) < 1e-9)
    }

    @Test
    func measuringStateCarriesAConsistentReadout() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .aperture, aperture: 16)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        let readout = try #require(currentReadout(viewModel))
        #expect(abs(readout.ev - Self.base) < 1e-9)
        #expect(readout.compensatedEV == readout.ev)
        #expect(readout.suggestion != nil)
        #expect(!readout.equivalents.isEmpty)
    }

    nonisolated static let reliableOffsets: [Double] = [0, 0.5, -0.5, 1, -1]

    @Test(arguments: MeterViewModelTests.reliableOffsets)
    func smallOffsetsKeepTheMeterMeasuring(offset: Double) async throws {
        let viewModel = try makeViewModel([Self.reading(offset: offset)])

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        guard case .measuring = viewModel.state else {
            Issue.record("Expected .measuring for offset \(offset), got \(viewModel.state)")
            return
        }
    }

    nonisolated static let unreliableOffsets: [Double] = [1.5, -1.5, 3, -3]

    @Test(arguments: MeterViewModelTests.unreliableOffsets)
    func largeOffsetsFlagTheReadingAsOutOfRange(offset: Double) async throws {
        let viewModel = try makeViewModel([Self.reading(offset: offset)])

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        guard case .outOfRange(let readout) = viewModel.state else {
            Issue.record("Expected .outOfRange for offset \(offset), got \(viewModel.state)")
            return
        }
        #expect(abs(readout.ev - (Self.base + offset)) < 1e-9)
    }

    @Test
    func recoversWhenTheOffsetReturnsToRange() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 2), Self.reading(offset: 0)])

        viewModel.start()
        let received = await waitUntil {
            if case .measuring = viewModel.state { return true }
            return false
        }
        #expect(received)
    }

    @Test
    func stopClearsTheOutOfRangeFlag() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 2)])

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        viewModel.stop()
        #expect(viewModel.state == .idle)
    }

    @Test
    func shutterModeComputesTheApertureFromTheChosenShutter() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .shutter, shutterSpeed: 1.0 / 125)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(suggestion.aperture == 16)
        #expect(suggestion.exposureTime == 1.0 / 125)
    }

    @Test
    func isoModeComputesTheISOFromApertureAndShutter() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .iso, aperture: 8, shutterSpeed: 1.0 / 1000)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(suggestion.aperture == 8)
        #expect(suggestion.exposureTime == 1.0 / 1000)
        #expect(suggestion.iso == 200)
    }

    @Test
    func changingTheModeUpdatesTheSuggestionWithoutNewReadings() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .aperture, aperture: 16, shutterSpeed: 1.0 / 1000)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)
        #expect(currentReadout(viewModel)?.suggestion?.exposureTime == 1.0 / 125)

        viewModel.mode = .shutter

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(suggestion.exposureTime == 1.0 / 1000)
        #expect(suggestion.aperture == 5.6)
    }

    @Test
    func changingTheChosenApertureUpdatesTheSuggestion() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], mode: .aperture, aperture: 16)

        viewModel.start()
        let received = await waitUntil { currentReadout(viewModel) != nil }
        #expect(received)

        viewModel.aperture = 8

        let suggestion = try #require(currentReadout(viewModel)?.suggestion)
        #expect(suggestion.aperture == 8)
        #expect(suggestion.exposureTime == 1.0 / 500)
    }
}
