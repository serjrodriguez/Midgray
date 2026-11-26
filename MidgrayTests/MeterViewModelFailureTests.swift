//
//  MeterViewModelFailureTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import Testing
@testable import Midgray

@MainActor
struct MeterViewModelFailureTests {
    nonisolated static let reading = CameraReading(aperture: 16, exposureTime: 1.0 / 125, iso: 100, exposureTargetOffset: 0)

    func makeViewModel(failures: Int) throws -> MeterViewModel {
        let smoother = try #require(EVSmoother())
        return MeterViewModel(sensor: FailingLightSensor(failures: failures, reading: Self.reading), smoother: smoother)
    }

    func settle() async {
        for _ in 0..<200 { await Task.yield() }
    }

    @Test
    func reportsTheFailureOfTheSensor() async throws {
        let viewModel = try makeViewModel(failures: 1)

        viewModel.start()
        await settle()

        #expect(viewModel.state == .failed)
        #expect(!viewModel.hasReading)
    }

    @Test
    func startingAgainRecoversFromAFailure() async throws {
        let viewModel = try makeViewModel(failures: 1)
        viewModel.start()
        await settle()

        viewModel.start()
        #expect(viewModel.state == .idle)
        await settle()

        #expect(viewModel.hasReading)
        #expect(!viewModel.hasFailed)
    }

    @Test
    func keepsFailingWhileTheSensorDoes() async throws {
        let viewModel = try makeViewModel(failures: 2)
        viewModel.start()
        await settle()

        viewModel.start()
        await settle()

        #expect(viewModel.state == .failed)
    }

    @Test
    func stoppingClearsTheFailure() async throws {
        let viewModel = try makeViewModel(failures: 1)
        viewModel.start()
        await settle()

        viewModel.stop()

        #expect(viewModel.state == .idle)
    }
}
