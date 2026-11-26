//
//  MeterViewModelObservationTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import Observation
import Synchronization
import Testing
@testable import Midgray

@MainActor
struct MeterViewModelObservationTests {
    func reading(offset: Double) -> CameraReading {
        CameraReading(aperture: 16, exposureTime: 1.0 / 125, iso: 100, exposureTargetOffset: offset)
    }

    func settle() async {
        for _ in 0..<200 { await Task.yield() }
    }

    @Test
    func repeatedReadingsDoNotInvalidateObservers() async throws {
        let sensor = ManualLightSensor()
        let smoother = try #require(EVSmoother())
        let viewModel = MeterViewModel(sensor: sensor, smoother: smoother)
        viewModel.start()
        sensor.send(reading(offset: 0))
        await settle()
        #expect(viewModel.hasReading)

        let changes = Mutex(0)
        withObservationTracking {
            _ = viewModel.state
        } onChange: {
            changes.withLock { $0 += 1 }
        }

        sensor.send(reading(offset: 0))
        await settle()
        #expect(changes.withLock { $0 } == 0)

        sensor.send(reading(offset: 2))
        await settle()
        #expect(changes.withLock { $0 } == 1)
        viewModel.stop()
    }
}
