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
                       priority: ExposurePriority = .aperture(5.6),
                       baseISO: Double = 100) throws -> MeterViewModel {
        let smoother = try #require(EVSmoother(smoothing: smoothing))
        return MeterViewModel(sensor: FakeLightSensor(scriptedReadings: readings),
                              smoother: smoother,
                              priority: priority,
                              baseISO: baseISO)
    }

    func waitUntil(_ condition: () -> Bool) async -> Bool {
        for _ in 0..<1000 {
            if condition() { return true }
            await Task.yield()
        }
        return condition()
    }

    @Test
    func startsWithoutEV() throws {
        let viewModel = try makeViewModel([])
        #expect(viewModel.ev == nil)
    }

    @Test
    func publishesTheSmoothedEV() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0), Self.reading(offset: 2)])
        let expected = Self.base + 1

        viewModel.start()

        let reached = await waitUntil { abs((viewModel.ev ?? .nan) - expected) < 1e-9 }
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

        let reached = await waitUntil { abs((viewModel.ev ?? .nan) - expected) < 1e-9 }
        #expect(reached)
    }

    @Test
    func stopClearsTheEV() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)])

        viewModel.start()
        let received = await waitUntil { viewModel.ev != nil }
        #expect(received)

        viewModel.stop()
        #expect(viewModel.ev == nil)
    }

    @Test
    func stopResetsTheSmoother() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 2)])

        viewModel.start()
        let first = await waitUntil { viewModel.ev != nil }
        #expect(first)
        viewModel.stop()

        viewModel.start()
        let reached = await waitUntil { abs((viewModel.ev ?? .nan) - (Self.base + 2)) < 1e-9 }
        #expect(reached)
    }

    @Test
    func withoutEVThereIsNoSuggestion() throws {
        let viewModel = try makeViewModel([])
        #expect(viewModel.suggestion == nil)
        #expect(viewModel.equivalents.isEmpty)
    }

    @Test
    func aperturePriorityGivesSunnySixteenTime() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], priority: .aperture(16))

        viewModel.start()
        let received = await waitUntil { viewModel.ev != nil }
        #expect(received)

        let suggestion = try #require(viewModel.suggestion)
        #expect(suggestion.aperture == 16)
        #expect(suggestion.iso == 100)
        #expect(abs(suggestion.exposureTime - 1.0 / 125) < 1e-9)
    }

    @Test
    func changingThePriorityUpdatesTheSuggestionWithoutNewReadings() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], priority: .aperture(16))

        viewModel.start()
        let received = await waitUntil { viewModel.ev != nil }
        #expect(received)

        viewModel.priority = .shutter(1.0 / 125)

        let suggestion = try #require(viewModel.suggestion)
        #expect(suggestion.exposureTime == 1.0 / 125)
        #expect(suggestion.aperture == 16)
    }

    @Test
    func changingTheBaseISOUpdatesTheSuggestion() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)], priority: .aperture(16))

        viewModel.start()
        let received = await waitUntil { viewModel.ev != nil }
        #expect(received)

        viewModel.baseISO = 200

        let suggestion = try #require(viewModel.suggestion)
        #expect(suggestion.iso == 200)
        #expect(suggestion.exposureTime < 1.0 / 125)
    }

    @Test
    func equivalentsMatchTheMeteredLight() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)])

        viewModel.start()
        let received = await waitUntil { viewModel.ev != nil }
        #expect(received)

        #expect(!viewModel.equivalents.isEmpty)
        #expect(viewModel.equivalents.allSatisfy { $0.iso == 100 && abs($0.evError) <= 0.5 })
    }

    @Test
    func stopRemovesTheSuggestion() async throws {
        let viewModel = try makeViewModel([Self.reading(offset: 0)])

        viewModel.start()
        let received = await waitUntil { viewModel.suggestion != nil }
        #expect(received)

        viewModel.stop()
        #expect(viewModel.suggestion == nil)
        #expect(viewModel.equivalents.isEmpty)
    }
}
