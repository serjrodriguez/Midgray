//
//  MeterView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI
import AVFoundation

struct MeterView: View {
    @State private var viewModel: MeterViewModel
    private let previewSession: AVCaptureSession?

    init(viewModel: MeterViewModel, previewSession: AVCaptureSession? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.previewSession = previewSession
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let previewSession {
                CameraPreview(session: previewSession)
                    .ignoresSafeArea()
                    .opacity(viewModel.isSwitchingLens ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isSwitchingLens)
            }

            content
        }
        .preferredColorScheme(.dark)
        .task { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ProgressView {
                Text("Measuring...")
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

            MeterPanel(viewModel: viewModel, readout: readout)
        }
        .padding(.horizontal, Spacing.s12)
        .padding(.bottom, Spacing.s8)
        .overlay(alignment: .topTrailing) {
            MeterToolbar(viewModel: viewModel)
                .padding(.horizontal, Spacing.s16)
                .padding(.top, Spacing.s8)
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
    }
}

#Preview("Midiendo") {
    MeterView(viewModel: MeterViewModel(sensor: SimulatedLightSensor(), smoother: EVSmoother()!))
}

#Preview("Fuera de rango") {
    MeterView(viewModel: MeterViewModel(sensor: SimulatedLightSensor(offsets: [2]), smoother: EVSmoother()!))
}
