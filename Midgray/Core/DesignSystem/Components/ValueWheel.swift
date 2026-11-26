//
//  ValueWheel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI
import UIKit

struct ValueWheel<Value: Hashable>: View {
    let title: LocalizedStringKey
    let values: [Value]
    @Binding var selection: Value
    @Binding var isScrolling: Bool
    let format: (Value) -> String

    @State private var position: Value?
    @State private var isPositioned = false
    @State private var feedback = UISelectionFeedbackGenerator()
    @ScaledMetric(relativeTo: .title) private var rowHeight: CGFloat = 44
    @ScaledMetric(relativeTo: .title) private var selectedSize: CGFloat = 26
    @ScaledMetric(relativeTo: .body) private var otherSize: CGFloat = 17

    init(title: LocalizedStringKey,
         values: [Value],
         selection: Binding<Value>,
         isScrolling: Binding<Bool>,
         format: @escaping (Value) -> String) {
        self.title = title
        self.values = values
        _selection = selection
        _isScrolling = isScrolling
        self.format = format
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radius.r14)
                .fill(Color.meterWheelBand)
                .frame(height: rowHeight)
                .padding(.horizontal, Spacing.s8)

            wheel
        }
        .frame(maxWidth: .infinity)
        .frame(height: rowHeight * 3 + Spacing.s16 * 2)
        .background(Color.meterWheelFill, in: RoundedRectangle(cornerRadius: Radius.r26))
        .overlay(alignment: .topLeading) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, Spacing.s8)
                .padding(.leading, Spacing.s12)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .topTrailing) {
            chevron("chevron.up")
                .padding(.top, Spacing.s8)
        }
        .overlay(alignment: .bottomTrailing) {
            chevron("chevron.down")
                .padding(.bottom, Spacing.s8)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.r26)
                .strokeBorder(Color.accentColor, lineWidth: 2.5)
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.5), radius: 24, y: 8)
        .onAppear { feedback.prepare() }
        .accessibilityElement()
        .accessibilityLabel(title)
        .accessibilityValue(format(selection))
        .accessibilityAdjustableAction(adjust)
    }

    private var wheel: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(values, id: \.self) { value in
                        let isSelected = value == selection

                        Text(format(value))
                            .font(.system(size: isSelected ? selectedSize : otherSize, weight: isSelected ? .semibold : .regular).monospacedDigit())
                            .foregroundStyle(.primary)
                            .opacity(isSelected ? 1 : 0.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: rowHeight)
                            .id(value)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $position, anchor: .center)
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.vertical, rowHeight, for: .scrollContent)
            .scrollIndicators(.hidden)
            .frame(height: rowHeight * 3)
            .onScrollGeometryChange(for: Int.self) { geometry in
                Int(((geometry.contentOffset.y + geometry.contentInsets.top) / rowHeight).rounded())
            } action: { _, _ in
                guard isPositioned else { return }

                feedback.selectionChanged()
                feedback.prepare()
            }
            .task {
                proxy.scrollTo(selection, anchor: .center)
                await Task.yield()
                position = selection
                isPositioned = true
            }
        }
        .onChange(of: position) { _, new in
            guard isPositioned, let new, new != selection else { return }
            selection = new
        }
        .onChange(of: selection) { _, new in
            guard isPositioned, position != new else { return }
            withAnimation(.snappy) { position = new }
        }
        .onScrollPhaseChange { _, phase in
            isScrolling = phase != .idle
        }
    }

    private func chevron(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(.secondary)
            .padding(.trailing, Spacing.s12)
            .allowsHitTesting(false)
    }

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        guard let index = values.firstIndex(of: selection) else { return }

        let target = direction == .increment ? index + 1 : index - 1
        guard values.indices.contains(target) else { return }

        selection = values[target]
    }
}

#Preview {
    @Previewable @State var aperture = 4.0
    @Previewable @State var isScrolling = false

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        ValueWheel(
            title: "Aperture",
            values: ExposureScale.apertures,
            selection: $aperture,
            isScrolling: $isScrolling,
            format: { ExposureFormatter.aperture($0) }
        )
        .frame(width: 113)
    }
    .preferredColorScheme(.dark)
}
