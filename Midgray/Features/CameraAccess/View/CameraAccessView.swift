//
//  CameraAccessView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct CameraAccessView: View {
    let access: CameraAccess
    let onRequest: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
            } icon: {
                Image(systemName: "video.slash")
            }
        } description: {
            Text(message)
        } actions: {
            if let actionTitle {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
            }
        }
    }

    private var title: LocalizedStringKey {
        switch access {
        case .denied: "Camera access is off"
        case .restricted: "Camera unavailable"
        case .undetermined, .granted: "Camera access"
        }
    }

    private var message: LocalizedStringKey {
        switch access {
        case .denied: "Turn on camera access for Midgray in Settings to measure light."
        case .restricted: "Camera access is restricted on this device, so Midgray cannot measure light."
        case .undetermined, .granted: "Midgray needs the camera to measure the light of a scene. It does not save photos or send data."
        }
    }

    private var actionTitle: LocalizedStringKey? {
        switch access {
        case .denied: "Open Settings"
        case .restricted: nil
        case .undetermined, .granted: "Allow camera"
        }
    }

    private var action: () -> Void {
        access == .denied ? onOpenSettings : onRequest
    }
}

#Preview("Sin decidir") {
    CameraAccessView(access: .undetermined, onRequest: {}, onOpenSettings: {})
        .preferredColorScheme(.dark)
}

#Preview("Denegado") {
    CameraAccessView(access: .denied, onRequest: {}, onOpenSettings: {})
        .preferredColorScheme(.dark)
}

#Preview("Restringido") {
    CameraAccessView(access: .restricted, onRequest: {}, onOpenSettings: {})
        .preferredColorScheme(.dark)
}
