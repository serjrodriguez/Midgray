//
//  EditableValueCell.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct EditableValueCell: View {
    let title: LocalizedStringKey
    let displayedValue: String
    let values: [Double]
    @Binding var selection: Double
    let format: (Double) -> String
    @Binding var isEditing: Bool
    @Binding var isInteracting: Bool

    @State private var isWheelScrolling = false
    @State private var scrubStartValue: Double?
    @State private var cellWidth: CGFloat = 0
    @ScaledMetric(relativeTo: .title) private var sideWheelWidth: CGFloat = 113
    @Environment(\.usesCompactValues) private var usesCompactValues

    private static let scrubStep: CGFloat = 28

    var body: some View {
        ValueCell(kind: .input, title: title, value: displayedValue)
            .overlay(alignment: .trailing) {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.trailing, Spacing.s8)
                    .opacity(isEditing ? 0 : 1)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(displayedValue)
            .accessibilityAdjustableAction(adjust)
            .accessibilityAction { open() }
            .accessibilityHidden(isEditing)
            .contentShape(Rectangle())
            .onTapGesture { isEditing ? close() : open() }
            .gesture(scrub)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.r16)
                    .strokeBorder(Color.accentColor, lineWidth: 2.5)
                    .opacity(isEditing ? 1 : 0)
                    .allowsHitTesting(false)
            }
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.width
            } action: { width in
                cellWidth = width
            }
            .popover(isPresented: $isEditing, arrowEdge: usesCompactValues ? .trailing : .bottom) {
                ValueWheel(title: title, values: values, selection: $selection, isScrolling: $isWheelScrolling, format: format)
                    .simultaneousGesture(TapGesture().onEnded { close() })
                    .frame(width: usesCompactValues ? sideWheelWidth : cellWidth)
                    .padding(Spacing.s8)
                    .presentationCompactAdaptation(.popover)
                    .presentationBackground(.clear)
            }
            .onChange(of: isWheelScrolling) { _, scrolling in
                isInteracting = scrolling
            }
    }

    private var scrub: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { gesture in
                let start = scrubStartValue ?? selection
                if scrubStartValue == nil {
                    scrubStartValue = start
                    isInteracting = true
                }
                isEditing = true

                let steps = Int((-gesture.translation.height / Self.scrubStep).rounded())
                if let target = ExposureScale.step(start, by: steps, in: values) {
                    selection = target
                }
            }
            .onEnded { _ in
                scrubStartValue = nil
                isInteracting = false
            }
    }

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        let steps = direction == .increment ? 1 : -1
        if let target = ExposureScale.step(selection, by: steps, in: values) {
            selection = target
        }
    }

    private func open() {
        isEditing = true
    }

    private func close() {
        isEditing = false
    }
}
