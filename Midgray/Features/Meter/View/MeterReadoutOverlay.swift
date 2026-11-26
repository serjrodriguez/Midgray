//
//  MeterReadoutOverlay.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import SwiftUI

struct MeterReadoutOverlay: View {
    let viewModel: MeterViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        switch viewModel.state {
        case .idle:
            ProgressView {
                Text("Measuring...")
            }
        case .failed:
            ContentUnavailableView {
                Label("Camera unavailable", systemImage: "video.slash")
            } description: {
                Text("Midgray could not start the camera. Close other apps that use it and try again.")
            } actions: {
                Button("Try again", action: viewModel.start)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
            }
        case .measuring(let readout):
            panel(readout, isOutOfRange: false)
        case .outOfRange(let readout):
            panel(readout, isOutOfRange: true)
        }
    }

    private func panel(_ readout: MeterReadout, isOutOfRange: Bool) -> some View {
        VStack(spacing: Spacing.s12) {
            Spacer()

            if isOutOfRange {
                OutOfRangeBadge()
            }

            if dynamicTypeSize.isAccessibilitySize {
                ScrollView {
                    MeterPanel(viewModel: viewModel, readout: readout)
                }
                .scrollBounceBehavior(.basedOnSize)
                .defaultScrollAnchor(.bottom)
            } else {
                MeterPanel(viewModel: viewModel, readout: readout)
            }
        }
        .padding(.horizontal, Spacing.s12)
        .padding(.bottom, Spacing.s8)
    }
}

private struct OutOfRangeBadge: View {
    var body: some View {
        Label("Out of range", systemImage: "exclamationmark.triangle.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, Spacing.s16)
            .frame(minHeight: Spacing.s32)
            .glassEffect(.regular.tint(.orange.opacity(0.35)), in: .capsule)
            .onAppear {
                AccessibilityNotification.Announcement(String(localized: "Out of range")).post()
            }
    }
}
