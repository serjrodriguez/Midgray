//
//  MeterViewModelHoldTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

@MainActor
struct MeterViewModelHoldTests {
    func makeViewModel() throws -> (MeterViewModel, ManualLightSensor) {
        let sensor = ManualLightSensor()
        let smoother = try #require(EVSmoother(smoothing: 1))
        return (MeterViewModel(sensor: sensor, smoother: smoother), sensor)
    }

    func currentEV(_ viewModel: MeterViewModel) -> Double? {
        switch viewModel.state {
        case .idle: nil
        case .measuring(let readout), .outOfRange(let readout): readout.ev
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
    func startsWithoutHold() throws {
        let (viewModel, _) = try makeViewModel()
        #expect(!viewModel.isHeld)
    }

    @Test
    func holdIsIgnoredBeforeTheFirstReading() throws {
        let (viewModel, _) = try makeViewModel()
        viewModel.toggleHold()
        #expect(!viewModel.isHeld)
    }

    @Test
    func holdFreezesTheReading() async throws {
        let (viewModel, sensor) = try makeViewModel()
        let base = MeterViewModelTests.base
        viewModel.start()

        sensor.send(MeterViewModelTests.reading(offset: 0))
        let measured = await waitUntil { currentEV(viewModel) != nil }
        #expect(measured)

        viewModel.toggleHold()
        sensor.send(MeterViewModelTests.reading(offset: 2))
        for _ in 0..<50 { await Task.yield() }

        #expect(viewModel.isHeld)
        let ev = try #require(currentEV(viewModel))
        #expect(abs(ev - base) < 1e-9)
    }

    @Test
    func resumingFollowsTheLightAgain() async throws {
        let (viewModel, sensor) = try makeViewModel()
        let base = MeterViewModelTests.base
        viewModel.start()

        sensor.send(MeterViewModelTests.reading(offset: 0))
        _ = await waitUntil { currentEV(viewModel) != nil }
        viewModel.toggleHold()
        sensor.send(MeterViewModelTests.reading(offset: 2))
        for _ in 0..<50 { await Task.yield() }

        viewModel.toggleHold()
        sensor.send(MeterViewModelTests.reading(offset: 4))

        let followed = await waitUntil { abs((currentEV(viewModel) ?? .nan) - (base + 4)) < 1e-9 }
        #expect(followed)
        #expect(!viewModel.isHeld)
    }

    @Test
    func stoppingReleasesTheHold() async throws {
        let (viewModel, sensor) = try makeViewModel()
        viewModel.start()

        sensor.send(MeterViewModelTests.reading(offset: 0))
        _ = await waitUntil { currentEV(viewModel) != nil }
        viewModel.toggleHold()
        viewModel.stop()

        #expect(!viewModel.isHeld)
        #expect(viewModel.state == .idle)
    }

    @Test
    func manualSettingsStillApplyWhileHeld() async throws {
        let (viewModel, sensor) = try makeViewModel()
        viewModel.start()

        sensor.send(MeterViewModelTests.reading(offset: 0))
        _ = await waitUntil { currentEV(viewModel) != nil }
        viewModel.toggleHold()
        viewModel.mode = .aperture
        viewModel.aperture = 8

        guard case .measuring(let readout) = viewModel.state else {
            Issue.record("Expected a measuring state")
            return
        }
        #expect(readout.suggestion?.aperture == 8)
    }
}
