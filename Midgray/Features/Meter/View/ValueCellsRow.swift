//
//  ValueCellsRow.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct ValueCellsRow: View {
    let mode: ExposureMode
    let suggestion: ExposureSuggestion?

    private static let placeholder = "—"

    var body: some View {
        HStack(spacing: Spacing.s8) {
            ValueCell(
                kind: kind(of: .aperture),
                title: "Aperture",
                value: suggestion.map { ExposureFormatter.aperture($0.aperture) } ?? Self.placeholder
            )
            ValueCell(
                kind: kind(of: .shutter),
                title: "Shutter",
                value: suggestion.map { ExposureFormatter.shutter($0.exposureTime) } ?? Self.placeholder
            )
            ValueCell(
                kind: kind(of: .iso),
                title: "ISO",
                value: suggestion.map { ExposureFormatter.isoValue($0.iso) } ?? Self.placeholder
            )
        }
    }

    private func kind(of setting: ExposureSetting) -> ValueCell.Kind {
        mode.role(of: setting) == .input ? .input : .result
    }
}

private let previewSuggestion = ExposureSuggestion(aperture: 5.6, exposureTime: 1.0 / 500, iso: 100, evError: 0)

#Preview("Modos") {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        VStack(spacing: Spacing.s16) {
            ForEach(ExposureMode.allCases, id: \.self) { mode in
                ValueCellsRow(mode: mode, suggestion: previewSuggestion)
            }
            ValueCellsRow(mode: .auto, suggestion: nil)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
