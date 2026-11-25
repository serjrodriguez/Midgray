//
//  EquivalentChip.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct EquivalentChip: View {
    let title: String
    let isSelected: Bool

    private var glass: Glass {
        isSelected ? .regular.tint(.accentColor).interactive() : .regular.interactive()
    }

    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .monospacedDigit()
            .foregroundStyle(.primary)
            .padding(.horizontal, Spacing.s16)
            .frame(minHeight: Spacing.s32)
            .glassEffect(glass, in: .capsule)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        HStack {
            EquivalentChip(title: "f/2.8 · 1/2000", isSelected: false)
            EquivalentChip(title: "f/4 · 1/1000", isSelected: false)
            EquivalentChip(title: "f/5.6 · 1/500", isSelected: true)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Texto grande") {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        VStack {
            EquivalentChip(title: "f/4 · 1/1000", isSelected: false)
            EquivalentChip(title: "f/5.6 · 1/500", isSelected: true)
        }
        .dynamicTypeSize(.accessibility3)
    }
    .preferredColorScheme(.dark)
}
