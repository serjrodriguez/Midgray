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

    func makeViewModel(_ readings: [CameraReading], smoothing: Double = 0.5) throws -> MeterViewModel {
        let smoother = try #require(EVSmoother(smoothing: smoothing))
        return MeterViewModel(sensor: FakeLightSensor(scriptedReadings: readings), smoother: smoother)
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
}
