//
//  MeterViewModelMeteringTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 25/11/26.
//

import Testing
import CoreGraphics
@testable import Midgray

@MainActor
struct MeterViewModelMeteringTests {
    nonisolated static let wide = CameraLens(id: "w", kind: .wide, zoomFactor: 1)
    nonisolated static let telephoto = CameraLens(id: "t", kind: .telephoto, zoomFactor: 3)

    func makeViewModel() throws -> (MeterViewModel, RecordingLightSensor) {
        let sensor = RecordingLightSensor(lenses: [Self.wide, Self.telephoto])
        let viewModel = MeterViewModel(sensor: sensor, smoother: try #require(EVSmoother()), lensSettleDelay: .zero)
        return (viewModel, sensor)
    }

    func waitUntil(_ condition: () -> Bool) async -> Bool {
        for _ in 0..<1000 {
            if condition() { return true }
            await Task.yield()
        }
        return condition()
    }

    @Test
    func startsAveragingTheWholeScene() throws {
        let (viewModel, _) = try makeViewModel()

        #expect(viewModel.meteringMode == .average)
        #expect(viewModel.spot == CGPoint(x: 0.5, y: 0.5))
    }

    @Test
    func switchingToSpotSendsTheCenterPoint() async throws {
        let (viewModel, sensor) = try makeViewModel()

        viewModel.setMeteringMode(.spot)

        #expect(viewModel.meteringMode == .spot)
        let sent = await waitUntil { sensor.meteringPoints == [CGPoint(x: 0.5, y: 0.5)] }
        #expect(sent)
    }

    @Test
    func switchingBackToAverageClearsThePoint() async throws {
        let (viewModel, sensor) = try makeViewModel()

        viewModel.setMeteringMode(.spot)
        viewModel.setMeteringMode(.average)

        let cleared = await waitUntil { sensor.meteringPoints.count == 2 && sensor.meteringPoints.last == .some(nil) }
        #expect(cleared)
    }

    @Test
    func choosingTheCurrentModeDoesNothing() async throws {
        let (viewModel, sensor) = try makeViewModel()

        viewModel.setMeteringMode(.average)
        for _ in 0..<50 { await Task.yield() }

        #expect(sensor.meteringPoints.isEmpty)
    }

    @Test
    func tappingInSpotModeStoresTheViewPointAndSendsTheDevicePoint() async throws {
        let (viewModel, sensor) = try makeViewModel()
        viewModel.setMeteringMode(.spot)

        viewModel.setSpot(viewPoint: CGPoint(x: 0.25, y: 0.75), devicePoint: CGPoint(x: 0.7, y: 0.2))

        #expect(viewModel.spot == CGPoint(x: 0.25, y: 0.75))
        let sent = await waitUntil { sensor.meteringPoints.last == .some(CGPoint(x: 0.7, y: 0.2)) }
        #expect(sent)
    }

    @Test
    func tapsAreIgnoredWhileAveraging() async throws {
        let (viewModel, sensor) = try makeViewModel()

        viewModel.setSpot(viewPoint: CGPoint(x: 0.1, y: 0.1), devicePoint: CGPoint(x: 0.1, y: 0.1))
        for _ in 0..<50 { await Task.yield() }

        #expect(viewModel.spot == CGPoint(x: 0.5, y: 0.5))
        #expect(sensor.meteringPoints.isEmpty)
    }

    @Test
    func outOfRangePointsAreClamped() async throws {
        let (viewModel, _) = try makeViewModel()
        viewModel.setMeteringMode(.spot)

        viewModel.setSpot(viewPoint: CGPoint(x: -1, y: 3), devicePoint: CGPoint(x: 2, y: -2))

        #expect(viewModel.spot == CGPoint(x: 0, y: 1))
    }

    @Test(arguments: [CGFloat.nan, CGFloat.infinity, -CGFloat.infinity])
    func nonFinitePointsAreIgnored(value: CGFloat) async throws {
        let (viewModel, sensor) = try makeViewModel()
        viewModel.setMeteringMode(.spot)
        let before = sensor.meteringPoints.count

        viewModel.setSpot(viewPoint: CGPoint(x: value, y: 0.5), devicePoint: CGPoint(x: 0.5, y: 0.5))
        viewModel.setSpot(viewPoint: CGPoint(x: 0.5, y: 0.5), devicePoint: CGPoint(x: 0.5, y: value))
        for _ in 0..<50 { await Task.yield() }

        #expect(viewModel.spot == CGPoint(x: 0.5, y: 0.5))
        #expect(sensor.meteringPoints.count <= before + 1)
    }

    @Test
    func changingLensResetsTheSpotToTheCenterAndResendsIt() async throws {
        let (viewModel, sensor) = try makeViewModel()
        viewModel.setMeteringMode(.spot)
        viewModel.setSpot(viewPoint: CGPoint(x: 0.2, y: 0.8), devicePoint: CGPoint(x: 0.9, y: 0.9))

        viewModel.selectLens(Self.telephoto)

        #expect(viewModel.spot == CGPoint(x: 0.5, y: 0.5))
        let resent = await waitUntil {
            sensor.selectedLenses == [Self.telephoto] && sensor.meteringPoints.last == .some(CGPoint(x: 0.5, y: 0.5))
        }
        #expect(resent)
    }

    @Test
    func changingLensWhileAveragingSendsNoPoint() async throws {
        let (viewModel, sensor) = try makeViewModel()

        viewModel.selectLens(Self.telephoto)

        let resent = await waitUntil { sensor.selectedLenses == [Self.telephoto] && sensor.meteringPoints.count == 1 }
        #expect(resent)
        #expect(sensor.meteringPoints.last == .some(nil))
    }

    @Test
    func resettingTheSpotReturnsItToTheCenter() throws {
        let smoother = try #require(EVSmoother())
        let viewModel = MeterViewModel(sensor: RecordingLightSensor(lenses: []), smoother: smoother)
        viewModel.setMeteringMode(.spot)
        viewModel.setSpot(viewPoint: CGPoint(x: 0.2, y: 0.3), devicePoint: CGPoint(x: 0.3, y: 0.8))

        viewModel.resetSpot()

        #expect(viewModel.spot == MeterViewModel.center)
    }
}
