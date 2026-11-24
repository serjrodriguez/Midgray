//
//  PrimaryActionButton.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct PrimaryActionButton: View {
    let title: LocalizedStringKey
    let isProminent: Bool
    let action: () -> Void

    private var glass: Glass {
        isProminent ? .regular.tint(.accentColor).interactive() : .regular.interactive()
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.s20)
                .padding(.vertical, Spacing.s8)
                .frame(maxWidth: .infinity, minHeight: 48)
                .glassEffect(glass, in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        VStack {
            PrimaryActionButton(title: "Medir", isProminent: true, action: {})
            PrimaryActionButton(title: "Retenido · toca para medir de nuevo", isProminent: false, action: {})
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Texto grande") {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        VStack {
            PrimaryActionButton(title: "Medir", isProminent: true, action: {})
            PrimaryActionButton(title: "Retenido · toca para medir de nuevo", isProminent: false, action: {})
        }
        .padding()
        .dynamicTypeSize(.accessibility3)
    }
    .preferredColorScheme(.dark)
}
