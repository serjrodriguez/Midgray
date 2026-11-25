//
//  MeterViewModelLensTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

@MainActor
struct MeterViewModelLensTests {
    nonisolated static let ultraWide = CameraLens(id: "u", kind: .ultraWide, zoomFactor: 0.5)
    nonisolated static let wide = CameraLens(id: "w", kind: .wide, zoomFactor: 1)
    nonisolated static let telephoto = CameraLens(id: "t", kind: .telephoto, zoomFactor: 3)

    func makeViewModel(lenses: [CameraLens]) throws -> (MeterViewModel, RecordingLightSensor) {
        let sensor = RecordingLightSensor(lenses: lenses)
        let smoother = try #require(EVSmoother())
        return (MeterViewModel(sensor: sensor, smoother: smoother, lensSettleDelay: .zero), sensor)
    }

    func waitUntil(_ condition: () -> Bool) async -> Bool {
        for _ in 0..<1000 {
            if condition() { return true }
            await Task.yield()
        }
        return condition()
    }

    @Test
    func startsOnTheWideLens() throws {
        let (viewModel, _) = try makeViewModel(lenses: [Self.ultraWide, Self.wide, Self.telephoto])
        #expect(viewModel.selectedLens == Self.wide)
    }

    @Test
    func fallsBackToTheFirstLensWithoutAWideOne() throws {
        let (viewModel, _) = try makeViewModel(lenses: [Self.telephoto])
        #expect(viewModel.selectedLens == Self.telephoto)
    }

    @Test
    func hasNoLensWhenTheSensorOffersNone() throws {
        let (viewModel, _) = try makeViewModel(lenses: [])
        #expect(viewModel.selectedLens == nil)
        #expect(viewModel.lenses.isEmpty)
    }

    @Test
    func selectingALensUpdatesTheStateAndTellsTheSensor() async throws {
        let (viewModel, sensor) = try makeViewModel(lenses: [Self.ultraWide, Self.wide])

        viewModel.selectLens(Self.ultraWide)

        #expect(viewModel.selectedLens == Self.ultraWide)
        let delivered = await waitUntil { sensor.selectedLenses == [Self.ultraWide] }
        #expect(delivered)
    }

    @Test
    func selectingTheCurrentLensDoesNothing() async throws {
        let (viewModel, sensor) = try makeViewModel(lenses: [Self.ultraWide, Self.wide])

        viewModel.selectLens(Self.wide)
        for _ in 0..<50 { await Task.yield() }

        #expect(sensor.selectedLenses.isEmpty)
    }

    @Test
    func unknownLensesAreIgnored() async throws {
        let (viewModel, sensor) = try makeViewModel(lenses: [Self.wide])

        viewModel.selectLens(Self.telephoto)
        for _ in 0..<50 { await Task.yield() }

        #expect(viewModel.selectedLens == Self.wide)
        #expect(sensor.selectedLenses.isEmpty)
    }

    @Test
    func switchingFlagIsRaisedAndThenReleased() async throws {
        let (viewModel, _) = try makeViewModel(lenses: [Self.ultraWide, Self.wide])
        #expect(!viewModel.isSwitchingLens)

        viewModel.selectLens(Self.ultraWide)
        #expect(viewModel.isSwitchingLens)

        let released = await waitUntil { !viewModel.isSwitchingLens }
        #expect(released)
    }

    @Test
    func ignoredSelectionsDoNotRaiseTheSwitchingFlag() throws {
        let (viewModel, _) = try makeViewModel(lenses: [Self.wide])
        viewModel.selectLens(Self.wide)
        #expect(!viewModel.isSwitchingLens)
    }
}
