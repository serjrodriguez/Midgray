//
//  SettingsViewModel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
import Observation

@Observable
final class SettingsViewModel {
    private(set) var calibration: Double
    private(set) var defaultLensID: String?

    let lenses: [CameraLens]
    let appInfo: AppInfo

    private let repository: any SettingsRepository
    private let saved: MeterSettings
    private let onSave: (MeterSettings) -> Void

    init(repository: any SettingsRepository,
         lenses: [CameraLens],
         appInfo: AppInfo = AppInfo(),
         onSave: @escaping (MeterSettings) -> Void) {
        let current = repository.load()

        self.repository = repository
        self.lenses = lenses
        self.appInfo = appInfo
        self.onSave = onSave
        self.saved = current
        self.calibration = Calibration.normalized(current.calibration)
        self.defaultLensID = current.defaultLensID
    }

    var draft: MeterSettings {
        MeterSettings(calibration: calibration, defaultLensID: defaultLensID)
    }

    var hasChanges: Bool {
        draft != saved
    }

    var defaultLens: CameraLens? {
        lenses.first { $0.id == defaultLensID } ?? lenses.first { $0.kind == .wide } ?? lenses.first
    }

    var canIncreaseCalibration: Bool {
        calibration < Calibration.range.upperBound
    }

    var canDecreaseCalibration: Bool {
        calibration > Calibration.range.lowerBound
    }

    var canResetCalibration: Bool {
        calibration != 0
    }

    func adjustCalibration(by steps: Int) {
        calibration = Calibration.stepped(calibration, by: steps)
    }

    func resetCalibration() {
        calibration = 0
    }

    func selectDefaultLens(_ lens: CameraLens) {
        guard lenses.contains(lens) else { return }
        defaultLensID = lens.id
    }

    func save() {
        let settings = draft
        repository.save(settings)
        onSave(settings)
    }
}

extension SettingsViewModel: Identifiable {
    var id: ObjectIdentifier { ObjectIdentifier(self) }
}
