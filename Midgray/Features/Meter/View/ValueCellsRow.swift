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
    @Binding var aperture: Double
    @Binding var shutterSpeed: Double
    @Binding var iso: Double

    @State private var editing: ExposureSetting?
    @State private var isInteracting = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.usesCompactValues) private var usesCompactValues

    nonisolated static let autoCloseDelay: Duration = .seconds(2)
    private static let placeholder = "—"

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize || usesCompactValues
            ? AnyLayout(VStackLayout(spacing: Spacing.s8))
            : AnyLayout(HStackLayout(spacing: Spacing.s8))
    }

    var body: some View {
        layout {
            cell(
                for: .aperture,
                title: "Aperture",
                scale: ExposureScale.apertures,
                value: $aperture,
                displayed: suggestion.map { ExposureFormatter.aperture($0.aperture) },
                format: { ExposureFormatter.aperture($0) }
            )
            cell(
                for: .shutter,
                title: "Shutter",
                scale: ExposureScale.shutterSpeeds,
                value: $shutterSpeed,
                displayed: suggestion.map { ExposureFormatter.shutter($0.exposureTime) },
                format: { ExposureFormatter.shutter($0) }
            )
            cell(
                for: .iso,
                title: "ISO",
                scale: ExposureScale.isoValues,
                value: $iso,
                displayed: suggestion.map { ExposureFormatter.isoValue($0.iso) },
                format: { ExposureFormatter.isoValue($0) }
            )
        }
        .onChange(of: mode) { editing = nil }
        .task(id: AutoCloseToken(editing: editing, isInteracting: isInteracting, aperture: aperture, shutterSpeed: shutterSpeed, iso: iso)) {
            guard editing != nil, !isInteracting else { return }

            try? await Task.sleep(for: Self.autoCloseDelay)
            guard !Task.isCancelled else { return }

            withAnimation(.snappy) { editing = nil }
        }
    }

    @ViewBuilder
    private func cell(for setting: ExposureSetting,
                      title: LocalizedStringKey,
                      scale: [Double],
                      value: Binding<Double>,
                      displayed: String?,
                      format: @escaping (Double) -> String) -> some View {
        if mode.role(of: setting) == .input {
            EditableValueCell(
                title: title,
                displayedValue: displayed ?? Self.placeholder,
                values: scale,
                selection: snapped(value, to: scale),
                format: format,
                isEditing: isEditing(setting),
                isInteracting: $isInteracting
            )
        } else {
            ValueCell(kind: .result, title: title, value: displayed ?? Self.placeholder)
        }
    }

    private func isEditing(_ setting: ExposureSetting) -> Binding<Bool> {
        Binding(
            get: { editing == setting },
            set: { editing = $0 ? setting : nil }
        )
    }

    private func snapped(_ value: Binding<Double>, to scale: [Double]) -> Binding<Double> {
        Binding(
            get: { ExposureScale.nearest(to: value.wrappedValue, in: scale) ?? value.wrappedValue },
            set: { value.wrappedValue = $0 }
        )
    }
}

private struct AutoCloseToken: Equatable {
    let editing: ExposureSetting?
    let isInteracting: Bool
    let aperture: Double
    let shutterSpeed: Double
    let iso: Double
}

private let previewSuggestion = ExposureSuggestion(aperture: 5.6, exposureTime: 1.0 / 500, iso: 100, evError: 0)

#Preview("Modos") {
    @Previewable @State var aperture = 5.6
    @Previewable @State var shutterSpeed = 1.0 / 125
    @Previewable @State var iso = 100.0

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        VStack(spacing: Spacing.s40) {
            ForEach(ExposureMode.allCases, id: \.self) { mode in
                ValueCellsRow(mode: mode, suggestion: previewSuggestion, aperture: $aperture, shutterSpeed: $shutterSpeed, iso: $iso)
            }
            ValueCellsRow(mode: .auto, suggestion: nil, aperture: $aperture, shutterSpeed: $shutterSpeed, iso: $iso)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
