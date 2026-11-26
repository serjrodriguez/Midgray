//
//  AppInfo.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated struct AppInfo: Equatable, Sendable {
    let version: String
    let build: String

    init(infoDictionary: [String: Any]? = Bundle.main.infoDictionary) {
        version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var versionDescription: String {
        "\(version) (\(build))"
    }
}
