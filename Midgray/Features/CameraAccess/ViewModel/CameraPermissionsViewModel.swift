//
//  CameraPermissionsViewModel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 23/11/26.
//

import Foundation
import Observation
import SrdzPermissionsCore

@Observable
final class CameraPermissionsViewModel {
    private(set) var access: CameraAccess = .undetermined
    private let permission: any PermissionProviding
    
    init(permission: any PermissionProviding) {
        self.permission = permission
    }
    
    func refresh() async {
        let status = await permission.status
        update(access: status)
    }
    
    func request() async {
        do {
            let statusResult = try await permission.requestAuthorization()
            update(access: statusResult)
        } catch { }
    }
    
    private func update(access status: PermissionStatus) {
        switch status {
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
