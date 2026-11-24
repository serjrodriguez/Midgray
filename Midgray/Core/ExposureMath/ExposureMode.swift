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