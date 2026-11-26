//
//  MeterViewModelSettingsTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

@MainActor
struct MeterViewModelSettingsTests {
    func currentEV(_ viewModel: MeterViewModel) -> Double? {
        switch viewModel.state {
        case .idle, .failed: nil
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

    func measuredViewModel() async throws -> MeterViewModel {
        let sensor = ManualLightSensor()
        let smoother = try #require(EVSmoother(smoothing: 1))
        let viewModel = MeterViewModel(sensor: sensor, smoother: smoother)
        viewModel.start()
        sensor.send(MeterViewModelTests.reading(offset: 0))
        let measured = await waitUntil { currentEV(viewModel) != nil }
        #expect(measured)
        return viewModel
    }

    @Test
    func startsWithoutCalibration() throws {
        let viewModel = MeterViewModel(sensor: ManualLightSensor(), smoother: try #require(EVSmoother()))
        #expect(viewModel.calibration == 0)
    }

    @Test
    func calibrationShiftsTheDisplayedEV() async throws {
        let viewModel = try await measuredViewModel()

        viewModel.apply(MeterSettings(calibration: 0.5, defaultLensID: nil))

        let ev = try #require(currentEV(viewModel))
        #expect(abs(ev - (MeterViewModelTests.base + 0.5)) < 1e-9)
    }

    @Test
    func calibrationAlsoShiftsTheSuggestion() async throws {
        let viewModel = try await measuredViewModel()
        guard case .measuring(let before) = viewModel.state else {
            Issue.record("Expected a measuring state")
            return
        }

        viewModel.apply(MeterSettings(calibration: 1, defaultLensID: nil))

        guard case .measuring(let after) = viewModel.state else {
            Issue.record("Expected a measuring state")
            return
        }
        #expect(after.compensatedEV == before.compensatedEV + 1)
    }

    @Test
    func compensationAndCalibrationAreIndependent() async throws {
        let viewModel = try await measuredViewModel()

        viewModel.apply(MeterSettings(calibration: 0.5, defaultLensID: nil))
        viewModel.setCompensation(1)

        guard case .measuring(let readout) = viewModel.state else {
            Issue.record("Expected a measuring state")
            return
        }
        #expect(abs(readout.ev - (MeterViewModelTests.base + 0.5)) < 1e-9)
        #expect(abs(readout.compensatedEV - (MeterViewModelTests.base - 0.5)) < 1e-9)
    }

    @Test
    func invalidCalibrationIsNormalized() throws {
        let viewModel = MeterViewModel(sensor: ManualLightSensor(), smoother: try #require(EVSmoother()))

        viewModel.apply(MeterSettings(calibration: 50, defaultLensID: nil))
        #expect(viewModel.calibration == 2)

        viewModel.apply(MeterSettings(calibration: .nan, defaultLensID: nil))
        #expect(viewModel.calibration == 0)
    }

    @Test
    func appliesTheDefaultLensWhenItExists() async throws {
        let ultraWide = CameraLens(id: "u", kind: .ultraWide, zoomFactor: 0.5)
        let wide = CameraLens(id: "w", kind: .wide, zoomFactor: 1)
        let sensor = RecordingLightSensor(lenses: [ultraWide, wide])
        let viewModel = MeterViewModel(sensor: sensor, smoother: try #require(EVSmoother()), lensSettleDelay: .zero)

        viewModel.apply(MeterSettings(calibration: 0, defaultLensID: "u"))

        #expect(viewModel.selectedLens == ultraWide)
        let delivered = await waitUntil { sensor.selectedLenses == [ultraWide] }
        #expect(delivered)
    }

    @Test
    func ignoresADefaultLensThatNoLongerExists() async throws {
        let wide = CameraLens(id: "w", kind: .wide, zoomFactor: 1)
        let sensor = RecordingLightSensor(lenses: [wide])
        let viewModel = MeterViewModel(sensor: sensor, smoother: try #require(EVSmoother()), lensSettleDelay: .zero)

        viewModel.apply(MeterSettings(calibration: 0, defaultLensID: "gone"))
        for _ in 0..<50 { await Task.yield() }

        #expect(viewModel.selectedLens == wide)
        #expect(sensor.selectedLenses.isEmpty)
    }
}
