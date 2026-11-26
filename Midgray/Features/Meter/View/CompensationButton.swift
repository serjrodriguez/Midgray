//
//  CompensationButton.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct CompensationButton: View {
    @Binding var compensation: Double

    @State private var isPresented = false
    @State private var isScrolling = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Text(label)
                .monospacedDigit()
                .foregroundStyle(compensation == 0 ? Color.primary : Color.accentColor)
        }
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
}

#Preview {
    @Previewable @State var compensation = 0.0
    @Previewable @State var other = 2.0 / 3

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        NavigationStack {
            Color.clear
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        CompensationButton(compensation: $compensation)
                        CompensationButton(compensation: $other)
                    }
                }
        }
    }
    .preferredColorScheme(.dark)
}
