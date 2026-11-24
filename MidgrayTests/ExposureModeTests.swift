//
//  ExposureModeTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

struct ExposureModeTests {
    nonisolated static let roles: [(ExposureMode, ExposureSetting, SettingRole)] = [
        (.auto, .aperture, .result), (.auto, .shutter, .result), (.auto, .iso, .input),
        (.aperture, .aperture, .input), (.aperture, .shutter, .result), (.aperture, .iso, .input),
        (.shutter, .aperture, .result), (.shutter, .shutter, .input), (.shutter, .iso, .input),
        (.iso, .aperture, .input), (.iso, .shutter, .input), (.iso, .iso, .result)
    ]

    @Test(arguments: ExposureModeTests.roles)
    func roleOfEachSettingMatchesTheDesign(mode: ExposureMode, setting: ExposureSetting, expected: SettingRole) {
        #expect(mode.role(of: setting) == expected)
    }

    @Test(arguments: ExposureMode.allCases)
    func everyModeComputesAtLeastOneSetting(mode: ExposureMode) {
        #expect(!mode.computedSettings.isEmpty)
    }

    @Test(arguments: ExposureMode.allCases)
    func everyModeLeavesAtLeastOneSettingToTheUser(mode: ExposureMode) {
        #expect(mode.computedSettings.count < ExposureSetting.allCases.count)
    }

    @Test
    func theTableCoversEveryModeAndSetting() {
        #expect(Self.roles.count == ExposureMode.allCases.count * ExposureSetting.allCases.count)
    }

    @Test
    func autoIsTheOnlyModeThatComputesTwoSettings() {
        let multiple = ExposureMode.allCases.filter { $0.computedSettings.count > 1 }
        #expect(multiple == [.auto])
    }
}
