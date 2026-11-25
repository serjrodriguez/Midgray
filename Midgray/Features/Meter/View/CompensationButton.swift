//
//  CompensationButton.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct CompensationButton: View {
    @Binding var compensation: Double

    private static let size: CGFloat = 48

    @State private var isPresented = false
    @State private var isScrolling = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Text(label)
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.primary)
                .frame(width: Self.size, height: Self.size)
                .glassEffect(glass, in: .circle)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented, arrowEdge: .top) {
            ValueWheel(
                title: "Exposure compensation",
                values: MeterViewModel.compensationValues,
                selection: $compensation,
                isScrolling: $isScrolling,
                format: { ExposureFormatter.compensation($0) }
            )
            .frame(width: 220)
            .padding(Spacing.s8)
            .presentationCompactAdaptation(.popover)
        }
        .accessibilityLabel("Exposure compensation")
        .accessibilityValue(ExposureFormatter.compensation(compensation))
    }

    private var label: String {
        compensation == 0 ? "±" : ExposureFormatter.compensation(compensation).replacingOccurrences(of: " EV", with: "")
    }

    private var glass: Glass {
        compensation == 0 ? .regular.interactive() : .regular.tint(.accentColor).interactive()
    }
}

#Preview {
    @Previewable @State var compensation = 0.0
    @Previewable @State var other = 2.0 / 3

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        HStack {
            CompensationButton(compensation: $compensation)
            CompensationButton(compensation: $other)
        }
    }
    .preferredColorScheme(.dark)
}
