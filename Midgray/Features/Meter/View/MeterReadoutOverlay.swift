//
//  MeterReadoutOverlay.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import SwiftUI

struct MeterReadoutOverlay: View {
    let viewModel: MeterViewModel
    let layout: MeterLayout
    var showsEquivalentsHeader = true
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let sideWidth: CGFloat = 340
    private static let maximumStackedWidth: CGFloat = 520

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var content: some View {
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
        Group {
            switch layout {
            case .stacked:
                stackedPanel(readout, isOutOfRange: isOutOfRange)
            case .side:
                sidePanel(readout, isOutOfRange: isOutOfRange)
            case .bottomHalf:
                bottomHalfPanel(readout, isOutOfRange: isOutOfRange)
            case .trailingHalf:
                trailingHalfPanel(readout, isOutOfRange: isOutOfRange)
            }
        }
        .padding(.horizontal, Spacing.s12)
        .padding(.bottom, Spacing.s8)
    }

    private func stackedPanel(_ readout: MeterReadout, isOutOfRange: Bool) -> some View {
        VStack(spacing: Spacing.s12) {
            Spacer()

            if isOutOfRange {
                OutOfRangeBadge()
            }

            scrollingIfNeeded {
                MeterPanel(viewModel: viewModel, readout: readout)
            }
        }
        .frame(maxWidth: Self.maximumStackedWidth)
    }

    private func bottomHalfPanel(_ readout: MeterReadout, isOutOfRange: Bool) -> some View {
        VStack(spacing: Spacing.s12) {
            if isOutOfRange {
                OutOfRangeBadge()
            }

            scrollingIfNeeded {
                MeterPanel(viewModel: viewModel, readout: readout)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Spacing.s12)
        .padding(.top, Spacing.s24)
    }

    private func sidePanel(_ readout: MeterReadout, isOutOfRange: Bool) -> some View {
        HStack(alignment: .bottom, spacing: Spacing.s16) {
            VStack(spacing: Spacing.s12) {
                Spacer()

                if isOutOfRange {
                    OutOfRangeBadge()
                }

                MeterEquivalents(viewModel: viewModel, showsHeader: showsEquivalentsHeader)
            }
            .frame(maxWidth: .infinity)

            compactPanel(readout)
                .frame(width: Self.sideWidth)
        }
    }

    private func trailingHalfPanel(_ readout: MeterReadout, isOutOfRange: Bool) -> some View {
        VStack(spacing: Spacing.s12) {
            Spacer(minLength: 0)

            if isOutOfRange {
                OutOfRangeBadge()
            }

            compactPanel(readout)
        }
    }

    private func compactPanel(_ readout: MeterReadout) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            scrollingIfNeeded {
                MeterPanel(viewModel: viewModel, readout: readout, showsEquivalents: false)
                    .environment(\.usesCompactValues, true)
            }
        }
    }

    @ViewBuilder
    private func scrollingIfNeeded(@ViewBuilder content: () -> some View) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                content()
            }
            .scrollBounceBehavior(.basedOnSize)
            .defaultScrollAnchor(.bottom)
        } else {
            content()
        }
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
