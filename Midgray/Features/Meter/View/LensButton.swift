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

    var body: some View {
        Menu {
            ForEach(lenses.reversed()) { lens in
                Button {
                    onSelect(lens)
                } label: {
                    if lens == selected {
                        Label(lens.title, systemImage: "checkmark")
                    } else {
                        Text(lens.title)
                    }
                }
            }
        } label: {
            Text(selected?.zoomLabel() ?? "1×")
                .monospacedDigit()
        }
        .accessibilityLabel("Lens")
        .accessibilityValue(selected?.title ?? "")
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

        NavigationStack {
            Color.clear
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        LensButton(lenses: lenses, selected: lenses[1], onSelect: { _ in })
                    }
                }
        }
    }
    .preferredColorScheme(.dark)
}
