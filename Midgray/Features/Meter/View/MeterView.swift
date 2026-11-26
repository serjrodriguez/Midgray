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
    @State private var containerSize = CGSize.zero
    @State private var controlsSize = CGSize.zero
    private let previewSession: AVCaptureSession?
    private let settings: any SettingsRepository

    private static let maximumHeightForEquivalentsHeader: CGFloat = 360

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

        if #available(iOS 27.1, *) {
            actions.axisBehavior(.verticalPreferred)
        } else {
            actions
        }
    }

    private var actions: some ToolbarContent {
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

            arrangement
                .onGeometryChange(for: CGSize.self) { geometry in
                    geometry.size
                } action: { size in
                    containerSize = size
                }
        }
    }

    @ViewBuilder
    private var arrangement: some View {
        if #available(iOS 27.1, *) {
            ArrangementView {
                controls
                    .overlayArrangementEdge(HorizontalEdge.trailing)
                    .overlayArrangementEdge(VerticalEdge.bottom)
            } secondary: {
                viewfinder
            }
            .arrangementViewStyle(.overlay)
        } else {
            ZStack {
                viewfinder
                controls
            }
        }
    }

    private var layout: MeterLayout {
        MeterLayout(size: controlsSize, container: containerSize)
    }

    private var viewfinder: some View {
        MeterViewfinder(viewModel: viewModel, previewSession: previewSession)
            .overlay(alignment: .bottomLeading) {
                if layout == .trailingHalf {
                    MeterEquivalents(viewModel: viewModel, showsHeader: false)
                        .padding(.horizontal, Spacing.s24)
                        .padding(.bottom, Spacing.s16)
                }
            }
    }

    private var controls: some View {
        MeterReadoutOverlay(
            viewModel: viewModel,
            layout: layout,
            showsEquivalentsHeader: controlsSize.height < Self.maximumHeightForEquivalentsHeader
        )
        .onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { size in
            controlsSize = size
        }
    }
}

#Preview("Midiendo") {
    MeterView(viewModel: MeterViewModel(sensor: SimulatedLightSensor(), smoother: EVSmoother()!))
}

#Preview("Fuera de rango") {
    MeterView(viewModel: MeterViewModel(sensor: SimulatedLightSensor(offsets: [2]), smoother: EVSmoother()!))
}
