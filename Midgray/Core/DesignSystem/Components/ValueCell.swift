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
    @ScaledMetric(relativeTo: .title3) private var compactValueSize: CGFloat = 20
    @Environment(\.usesCompactValues) private var isCompact

    private var valueColor: Color {
        kind == .result ? .meterResultText : .primary
    }

    private var fillColor: Color {
        kind == .result ? .meterResultFill : .meterInputFill
    }

    private var titleColor: Color {
        kind == .result ? .meterResultSecondaryText : .secondary
    }

    private var layout: AnyLayout {
        isCompact
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
    }

    var body: some View {
        layout {
            Text(title)
                .font(.caption2)
                .foregroundStyle(titleColor)

            if isCompact {
                Spacer(minLength: Spacing.s8)
            }

            Text(value)
                .font(.system(size: isCompact ? compactValueSize : valueSize, weight: .semibold).monospacedDigit())
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.leading, Spacing.s12)
        .padding(.trailing, isCompact && kind == .input ? Spacing.s24 : Spacing.s12)
        .padding(.vertical, isCompact ? Spacing.s4 : Spacing.s8)
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
