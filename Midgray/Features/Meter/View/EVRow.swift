//
//  EVRow.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct EVRow: View {
    let ev: Double
    let compensation: Double

    var body: some View {
        HStack {
            Text(ExposureFormatter.ev(ev))
                .font(.footnote)
                .foregroundStyle(.primary)
                .padding(.horizontal, Spacing.s12)
                .frame(minHeight: Spacing.s32)
                .glassEffect(.regular, in: .capsule)

            Spacer()

            Text(ExposureFormatter.compensation(compensation))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        VStack(spacing: Spacing.s16) {
            EVRow(ev: 14, compensation: 0)
            EVRow(ev: 9.3, compensation: 2.0 / 3)
            EVRow(ev: -1.7, compensation: -1)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Texto grande") {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        EVRow(ev: 14, compensation: 1.0 / 3)
            .padding()
            .dynamicTypeSize(.accessibility3)
    }
    .preferredColorScheme(.dark)
}
