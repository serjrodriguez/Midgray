//
//  CameraPermissionsViewModel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation
import SrdzPermissionsCore

nonisolated enum CameraAccess: Equatable {
    case undetermined
    case granted
    case denied
    case restricted
}

@Observable
final class CameraPermissionsViewModel {
    private(set) var access: CameraAccess = .undetermined
    private let permission: any PermissionProviding
    
    init(permission: any PermissionProviding) {
        self.permission = permission
    }
    
    func refresh() async {
        let status = await permission.status
        setPermissions(status)
    }
    
    func request() async {
        do {
            let statusResult = try await permission.requestAuthorization()
            setPermissions(statusResult)
        } catch { }
    }
    
    private func setPermissions(_ status: PermissionStatus) {
        switch  status {
            case .authorized, .limited:
                access = .granted
            case .denied:
                access = .denied
            case .restricted:
                access = .restricted
            case .notDetermined:
                access = .undetermined
        }
    }
}
