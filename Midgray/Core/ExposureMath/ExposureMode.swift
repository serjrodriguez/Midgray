//
//  ExposureMode.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

nonisolated enum ExposureMode: CaseIterable, Hashable, Sendable {
    case auto
    case aperture
    case shutter
    case iso
}

nonisolated enum ExposureSetting: CaseIterable, Hashable, Sendable {
    case aperture
    case shutter
    case iso
}

nonisolated enum SettingRole: Hashable, Sendable {
    case input
    case result
}

nonisolated extension ExposureMode {
    var computedSettings: Set<ExposureSetting> {
        switch self {
        case .auto:
            [.aperture, .shutter]
        case .aperture:
            [.shutter]
        case .shutter:
            [.aperture]
        case .iso:
            [.iso]
        }
    }

    func role(of setting: ExposureSetting) -> SettingRole {
        computedSettings.contains(setting) ? .result : .input
    }
}
