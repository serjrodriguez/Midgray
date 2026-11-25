//
//  SettingsViewModelTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

@MainActor
struct SettingsViewModelTests {
    nonisolated static let ultraWide = CameraLens(id: "u", kind: .ultraWide, zoomFactor: 0.5)
    nonisolated static let wide = CameraLens(id: "w", kind: .wide, zoomFactor: 1)
    nonisolated static let telephoto = CameraLens(id: "t", kind: .telephoto, zoomFactor: 3)

    final class Recorder {
        var received: [MeterSettings] = []
    }

    func makeViewModel(stored: MeterSettings = .standard,
                       lenses: [CameraLens] = [ultraWide, wide, telephoto]) -> (SettingsViewModel, InMemorySettingsRepository, Recorder) {
        let repository = InMemorySettingsRepository(stored)
        let recorder = Recorder()
        let viewModel = SettingsViewModel(repository: repository, lenses: lenses) { recorder.received.append($0) }
        return (viewModel, repository, recorder)
    }

    @Test
    func startsFromTheStoredSettings() {
        let (viewModel, _, _) = makeViewModel(stored: MeterSettings(calibration: 0.4, defaultLensID: "t"))

        #expect(viewModel.calibration == 0.4)
        #expect(viewModel.defaultLensID == "t")
        #expect(!viewModel.hasChanges)
    }

    @Test
    func editsAreOnlyADraftUntilSaved() {
        let (viewModel, repository, recorder) = makeViewModel()

        viewModel.adjustCalibration(by: 3)

        #expect(viewModel.calibration == 0.3)
        #expect(viewModel.hasChanges)
        #expect(repository.load() == .standard)
        #expect(recorder.received.isEmpty)
    }

    @Test
    func savePersistsAndNotifiesTheDraft() {
        let (viewModel, repository, recorder) = makeViewModel()

        viewModel.adjustCalibration(by: -2)
        viewModel.selectDefaultLens(Self.telephoto)
        viewModel.save()

        let expected = MeterSettings(calibration: -0.2, defaultLensID: "t")
        #expect(repository.load() == expected)
        #expect(repository.saveCount == 1)
        #expect(recorder.received == [expected])
    }

    @Test
    func calibrationStopsAtTheLimits() {
        let (viewModel, _, _) = makeViewModel(stored: MeterSettings(calibration: 1.9, defaultLensID: nil))

        viewModel.adjustCalibration(by: 5)
        #expect(viewModel.calibration == 2)
        #expect(!viewModel.canIncreaseCalibration)
        #expect(viewModel.canDecreaseCalibration)

        viewModel.adjustCalibration(by: -100)
        #expect(viewModel.calibration == -2)
        #expect(!viewModel.canDecreaseCalibration)
    }

    @Test
    func resetClearsTheCalibration() {
        let (viewModel, _, _) = makeViewModel(stored: MeterSettings(calibration: 0.8, defaultLensID: nil))
        #expect(viewModel.canResetCalibration)

        viewModel.resetCalibration()

        #expect(viewModel.calibration == 0)
        #expect(!viewModel.canResetCalibration)
    }

    @Test
    func revertingTheDraftToTheStoredValuesClearsTheChanges() {
        let (viewModel, _, _) = makeViewModel()

        viewModel.adjustCalibration(by: 2)
        viewModel.adjustCalibration(by: -2)

        #expect(!viewModel.hasChanges)
    }

    @Test
    func defaultLensFallsBackToTheWideLens() {
        let (viewModel, _, _) = makeViewModel()
        #expect(viewModel.defaultLens == Self.wide)
    }

    @Test
    func defaultLensFallsBackWhenTheStoredOneIsGone() {
        let (viewModel, _, _) = makeViewModel(stored: MeterSettings(calibration: 0, defaultLensID: "removed"))
        #expect(viewModel.defaultLens == Self.wide)
    }

    @Test
    func unknownLensesCannotBeSelected() {
        let (viewModel, _, _) = makeViewModel(lenses: [Self.wide])

        viewModel.selectDefaultLens(Self.telephoto)

        #expect(viewModel.defaultLensID == nil)
        #expect(!viewModel.hasChanges)
    }

    @Test
    func hasNoDefaultLensWithoutLenses() {
        let (viewModel, _, _) = makeViewModel(lenses: [])
        #expect(viewModel.defaultLens == nil)
    }
}
