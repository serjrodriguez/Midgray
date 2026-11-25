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
    @State private var settingsViewModel: SettingsViewModel?
    private let previewSession: AVCaptureSession?
    private let settings: any SettingsRepository

    init(viewModel: MeterViewModel,
         previewSession: AVCaptureSession? = nil,
         settings: any SettingsRepository = InMemorySettingsRepository()) {
        _viewModel = State(initialValue: viewModel)
        self.previewSession = previewSession
        self.settings = settings
    }

    var body: some View {
        NavigationStack {
            screen
                .toolbar { toolbar }
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
        .sheet(item: $settingsViewModel) { SettingsView(viewModel: $0) }
        .preferredColorScheme(.dark)
        .task { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                settingsViewModel = makeSettingsViewModel()
            } label: {
                Image(systemName: "gearshape")
            }
            .accessibilityLabel("Settings")
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            if viewModel.lenses.count > 1 {
                LensButton(
                    lenses: viewModel.lenses,
                    selected: viewModel.selectedLens,
                    onSelect: viewModel.selectLens
                )
            }

            MeteringButton(mode: viewModel.meteringMode, onSelect: viewModel.setMeteringMode)

            CompensationButton(compensation: compensationBinding)
        }
    }

    private var compensationBinding: Binding<Double> {
        Binding(
            get: { viewModel.compensation },
            set: { viewModel.setCompensation($0) }
        )
    }

    private func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(repository: settings, lenses: viewModel.lenses) { [viewModel] in
            viewModel.apply($0)
        }
    }

    private var screen: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            background

            content
        }
    }

    private var background: some View {
        GeometryReader { geometry in
            ZStack {
                if let previewSession {
                    CameraPreview(session: previewSession, onTap: handleSpotTap)
                        .opacity(viewModel.isSwitchingLens ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isSwitchingLens)
                } else {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            let point = CGPoint(x: location.x / geometry.size.width, y: location.y / geometry.size.height)
                            handleSpotTap(viewPoint: point, devicePoint: point)
                        }
                }

                if viewModel.meteringMode == .spot, viewModel.state != .idle {
                    SpotReticle()
                        .position(x: viewModel.spot.x * geometry.size.width, y: viewModel.spot.y * geometry.size.height)
                        .animation(.snappy, value: viewModel.spot)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func handleSpotTap(viewPoint: CGPoint, devicePoint: CGPoint) {
        viewModel.setSpot(viewPoint: viewPoint, devicePoint: devicePoint)
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
