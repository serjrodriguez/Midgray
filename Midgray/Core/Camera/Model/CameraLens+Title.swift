//
//  CameraLens+Title.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

extension CameraLens {
    var title: String {
        let name: LocalizedStringResource = switch kind {
        case .ultraWide: "Ultra wide"
        case .wide: "Wide"
        case .telephoto: "Telephoto"
        }
        return "\(String(localized: name)) · \(zoomLabel())"
    }
}
