//
//  ValueCell.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct ValueCell: View {
    enum Kind {
        case input
        case result
    }

    let kind: Kind
    let title: LocalizedStringKey
    let value: String

    @ScaledMetric(relativeTo: .title) private var valueSize: CGFloat = 24

    private var valueColor: Color {
        kind == .result ? .meterResultText : .primary
    }

    private var fillColor: Color {
        kind == .result ? .meterResultFill : .meterInputFill
    }

    private var titleColor: Color {
        kind == .result ? .meterResultSecondaryText : .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(titleColor)
            Text(value)
                .font(.system(size: valueSize, weight: .semibold).monospacedDigit())
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, Spacing.s12)
        .padding(.vertical, Spacing.s8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fillColor, in: RoundedRectangle(cornerRadius: Radius.r16))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.r16)
                .strokeBorder(Color.meterInputBorder, lineWidth: kind == .input ? 1 : 0)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        HStack {
            ValueCell(kind: .input, title: "Aperture", value: "f/5.6")
            ValueCell(kind: .result, title: "Shutter", value: "1/500 s")
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
