//
//  SettingsRepository.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

protocol SettingsRepository {
    func load() -> MeterSettings
    func save(_ settings: MeterSettings)
}

struct UserDefaultsSettingsRepository: SettingsRepository {
    private enum Key {
        static let calibration = "settings.calibration"
        static let defaultLensID = "settings.defaultLensID"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> MeterSettings {
        let calibration = defaults.object(forKey: Key.calibration) as? Double ?? 0
        let lensID = defaults.string(forKey: Key.defaultLensID)

        return MeterSettings(
            calibration: Calibration.normalized(calibration),
            defaultLensID: lensID?.isEmpty == false ? lensID : nil
        )
    }

    func save(_ settings: MeterSettings) {
        defaults.set(Calibration.normalized(settings.calibration), forKey: Key.calibration)

        if let lensID = settings.defaultLensID, !lensID.isEmpty {
            defaults.set(lensID, forKey: Key.defaultLensID)
        } else {
            defaults.removeObject(forKey: Key.defaultLensID)
        }
    }
}

final class InMemorySettingsRepository: SettingsRepository {
    private var stored: MeterSettings
    private(set) var saveCount = 0

    init(_ settings: MeterSettings = .standard) {
        stored = settings
    }

    func load() -> MeterSettings {
        stored
    }

    func save(_ settings: MeterSettings) {
        stored = settings
        saveCount += 1
    }
}
