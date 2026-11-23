//
//  CameraPermissionsViewModelTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Testing
import SrdzPermissionsCore
import SrdzPermissionsTesting
@testable import Midgray

@MainActor
struct CameraPermissionsViewModelTests {
    nonisolated static let statusMappings: [(PermissionStatus, CameraAccess)] = [
        (.authorized, .granted),
        (.limited, .granted),
        (.denied, .denied),
        (.restricted, .restricted),
        (.notDetermined, .undetermined)
    ]

    @Test
    func startsUndetermined() {
        let viewModel = CameraPermissionsViewModel(permission: FakePermissionProvider())
        #expect(viewModel.access == .undetermined)
    }

    @Test(arguments: CameraPermissionsViewModelTests.statusMappings)
    func refreshMapsTheSystemStatus(status: PermissionStatus, expected: CameraAccess) async {
        let viewModel = CameraPermissionsViewModel(permission: FakePermissionProvider(status: status))
        await viewModel.refresh()
        #expect(viewModel.access == expected)
    }

    @Test(arguments: [
        (PermissionStatus.authorized, CameraAccess.granted),
        (PermissionStatus.denied, CameraAccess.denied)
    ])
    func requestAppliesTheUserDecision(result: PermissionStatus, expected: CameraAccess) async {
        let provider = FakePermissionProvider(status: .notDetermined, authorizationResult: result)
        let viewModel = CameraPermissionsViewModel(permission: provider)
        await viewModel.request()
        #expect(viewModel.access == expected)
    }

    @Test
    func requestAsksTheProviderOnce() async {
        let provider = FakePermissionProvider(status: .notDetermined, authorizationResult: .authorized)
        let viewModel = CameraPermissionsViewModel(permission: provider)
        await viewModel.request()
        #expect(await provider.requestCount == 1)
    }

    @Test
    func requestKeepsDeniedWhenTheUserAlreadyDenied() async {
        let provider = FakePermissionProvider(status: .denied, authorizationResult: .authorized)
        let viewModel = CameraPermissionsViewModel(permission: provider)
        await viewModel.request()
        #expect(viewModel.access == .denied)
    }

    @Test
    func requestFailureKeepsThePreviousAccess() async {
        let provider = FakePermissionProvider(status: .denied, authorizationError: .timeout)
        let viewModel = CameraPermissionsViewModel(permission: provider)
        await viewModel.refresh()
        await viewModel.request()
        #expect(viewModel.access == .denied)
    }
}
