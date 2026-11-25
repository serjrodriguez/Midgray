//
//  AppInfoTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

struct AppInfoTests {
    @Test
    func readsTheVersionAndBuild() {
        let info = AppInfo(infoDictionary: ["CFBundleShortVersionString": "2.1", "CFBundleVersion": "34"])
        #expect(info.versionDescription == "2.1 (34)")
    }

    @Test
    func fallsBackWhenTheKeysAreMissing() {
        #expect(AppInfo(infoDictionary: nil).versionDescription == "1.0 (1)")
        #expect(AppInfo(infoDictionary: [:]).versionDescription == "1.0 (1)")
    }
}
