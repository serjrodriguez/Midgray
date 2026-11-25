//
//  CameraLens.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation

nonisolated struct CameraLens: Identifiable, Hashable, Sendable {
    enum Kind: Sendable {
        case ultraWide
        case wide
        case telephoto
    }

    let id: String
    let kind: Kind
    let zoomFactor: Double

    static func zoomFactor(fieldOfView: Double, referenceFieldOfView: Double) -> Double? {
        guard fieldOfView.isFinite, referenceFieldOfView.isFinite,
              fieldOfView > 0, fieldOfView < 180,
              referenceFieldOfView > 0, referenceFieldOfView < 180 else { return nil }

        let ratio = tan(referenceFieldOfView * .pi / 360) / tan(fieldOfView * .pi / 360)
        return (ratio * 2).rounded() / 2
    }

    func zoomLabel(locale: Locale = .current) -> String {
        zoomFactor.formatted(.number.precision(.fractionLength(0...1)).locale(locale)) + "×"
    }
}
