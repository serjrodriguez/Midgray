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

            MeterViewfinder(viewModel: viewModel, previewSession: previewSession)

            MeterReadoutOverlay(viewModel: viewModel)
        }
    }
}

#Preview("Midiendo") {
    MeterView(viewModel: MeterViewModel(sensor: SimulatedLightSensor(), smoother: EVSmoother()!))
}

#Preview("Fuera de rango") {
    MeterView(viewModel: MeterViewModel(sensor: SimulatedLightSensor(offsets: [2]), smoother: EVSmoother()!))
}
