//
//  LensButton.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct LensButton: View {
    let lenses: [CameraLens]
    let selected: CameraLens?
    let onSelect: (CameraLens) -> Void

    private static let size: CGFloat = 48

    var body: some View {
        Menu {
            ForEach(lenses.reversed()) { lens in
                Button {
                    onSelect(lens)
                } label: {
                    if lens == selected {
                        Label(title(for: lens), systemImage: "checkmark")
                    } else {
                        Text(title(for: lens))
                    }
                }
            }
        } label: {
            Text(selected?.zoomLabel() ?? "1×")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.primary)
                .frame(width: Self.size, height: Self.size)
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .accessibilityLabel("Lens")
        .accessibilityValue(selected.map(title(for:)) ?? "")
    }

    private func title(for lens: CameraLens) -> String {
        let name: LocalizedStringResource = switch lens.kind {
        case .ultraWide: "Ultra wide"
        case .wide: "Wide"
        case .telephoto: "Telephoto"
        }
        return "\(String(localized: name)) · \(lens.zoomLabel())"
    }
}

#Preview {
    let lenses = [
        CameraLens(id: "a", kind: .ultraWide, zoomFactor: 0.5),
        CameraLens(id: "b", kind: .wide, zoomFactor: 1),
        CameraLens(id: "c", kind: .telephoto, zoomFactor: 5)
    ]

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        LensButton(lenses: lenses, selected: lenses[1], onSelect: { _ in })
    }
    .preferredColorScheme(.dark)
}
