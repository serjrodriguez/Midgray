//
//  SettingsRepositoryTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
import Foundation
@testable import Midgray

@MainActor
struct SettingsRepositoryTests {
    func makeDefaults() throws -> (UserDefaults, String) {
        let name = "SettingsRepositoryTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        return (defaults, name)
    }

    @Test
    func loadsStandardSettingsWhenNothingIsStored() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        #expect(UserDefaultsSettingsRepository(defaults: defaults).load() == .standard)
    }

    @Test
    func savesAndLoadsTheSettings() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let repository = UserDefaultsSettingsRepository(defaults: defaults)
        let settings = MeterSettings(calibration: -0.7, defaultLensID: "lens-1")

        repository.save(settings)

        #expect(UserDefaultsSettingsRepository(defaults: defaults).load() == settings)
    }

    @Test
    func clearingTheLensRemovesTheStoredValue() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let repository = UserDefaultsSettingsRepository(defaults: defaults)

        repository.save(MeterSettings(calibration: 0, defaultLensID: "lens-1"))
        repository.save(MeterSettings(calibration: 0, defaultLensID: nil))

        #expect(repository.load().defaultLensID == nil)
    }

    @Test
    func invalidStoredCalibrationIsSanitized() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(99.0, forKey: "settings.calibration")

        #expect(UserDefaultsSettingsRepository(defaults: defaults).load().calibration == 2)
    }

    @Test
    func savingAnOutOfRangeCalibrationStoresTheClampedValue() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let repository = UserDefaultsSettingsRepository(defaults: defaults)

        repository.save(MeterSettings(calibration: -10, defaultLensID: nil))

        #expect(repository.load().calibration == -2)
    }

    @Test
    func emptyLensIdentifiersAreTreatedAsMissing() throws {
        let (defaults, name) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set("", forKey: "settings.defaultLensID")

        #expect(UserDefaultsSettingsRepository(defaults: defaults).load().defaultLensID == nil)
    }
}
