//
//  EquivalentsRow.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct EquivalentsRow: View {
    let equivalents: [ExposureSuggestion]
    let selectedAperture: Double?
    let ev: Double
    let onSelect: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Equivalent exposures for \(ExposureFormatter.ev(ev))")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal) {
                GlassEffectContainer {
                    HStack(spacing: Spacing.s8) {
                        ForEach(equivalents, id: \.aperture) { equivalent in
                            Button {
                                onSelect(equivalent.aperture)
                            } label: {
                                EquivalentChip(
                                    title: ExposureFormatter.equivalent(
                                        aperture: equivalent.aperture,
                                        exposureTime: equivalent.exposureTime
                                    ),
                                    isSelected: equivalent.aperture == selectedAperture
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }
}

#Preview {
    let equivalents = ExposureSuggestion.equivalents(ev100: 14.97, iso: 100)

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        GlassPanel {
            EquivalentsRow(equivalents: equivalents, selectedAperture: 5.6, ev: 14.97, onSelect: { _ in })
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Texto grande") {
    let equivalents = ExposureSuggestion.equivalents(ev100: 14.97, iso: 100)

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        GlassPanel {
            EquivalentsRow(equivalents: equivalents, selectedAperture: 5.6, ev: 14.97, onSelect: { _ in })
        }
        .padding()
        .dynamicTypeSize(.accessibility3)
    }
    .preferredColorScheme(.dark)
}
