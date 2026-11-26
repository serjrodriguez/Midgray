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
    var showsHeader = true
    var headerHasBackground = false
    let onSelect: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            if showsHeader {
                header
            }

            ScrollViewReader { proxy in
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
                                .id(equivalent.aperture)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .mask { edgeFade }
                .onAppear {
                    scrollToSelection(with: proxy, animated: false)
                }
                .onChange(of: selectedAperture) {
                    scrollToSelection(with: proxy, animated: true)
                }
            }
        }
    }
}

private extension EquivalentsRow {
    @ViewBuilder
    var header: some View {
        let title = Text("Equivalent exposures for \(ExposureFormatter.ev(ev))")
            .font(.caption2)

        if headerHasBackground {
            title
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.horizontal, Spacing.s12)
                .padding(.vertical, Spacing.s8)
                .glassEffect(.regular, in: .capsule)
        } else {
            title
                .foregroundStyle(.secondary)
        }
    }

    var edgeFade: some View {
        HStack(spacing: 0) {
            LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                .frame(width: Spacing.s12)
            Rectangle()
            LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: Spacing.s12)
        }
    }

    func scrollToSelection(with proxy: ScrollViewProxy, animated: Bool) {
        guard let selectedAperture else { return }

        if animated {
            withAnimation { proxy.scrollTo(selectedAperture, anchor: .center) }
        } else {
            proxy.scrollTo(selectedAperture, anchor: .center)
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
