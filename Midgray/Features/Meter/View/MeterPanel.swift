//
//  MeterPanel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct MeterPanel: View {
    @Bindable var viewModel: MeterViewModel
    let readout: MeterReadout

    var body: some View {
        GlassPanel {
            VStack(spacing: Spacing.s12) {
                modePicker

                if viewModel.mode == .auto {
                    EquivalentsRow(
                        equivalents: readout.equivalents,
                        selectedAperture: readout.suggestion?.aperture,
                        ev: readout.compensatedEV,
                        onSelect: viewModel.selectAutoAperture
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ValueCellsRow(
                    mode: viewModel.mode,
                    suggestion: readout.suggestion,
                    aperture: $viewModel.aperture,
                    shutterSpeed: $viewModel.shutterSpeed,
                    iso: $viewModel.baseISO
                )
                EVRow(ev: readout.ev, compensation: viewModel.compensation)

                PrimaryActionButton(title: holdTitle, isProminent: !viewModel.isHeld, action: viewModel.toggleHold)
            }
        }
    }

    private var holdTitle: LocalizedStringKey {
        viewModel.isHeld ? "Held · tap to measure again" : "Measure"
    }

    private var modePicker: some View {
        Picker("Exposure mode", selection: $viewModel.mode) {
            ForEach(ExposureMode.allCases, id: \.self) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }
}

private extension ExposureMode {
    var title: LocalizedStringKey {
        switch self {
        case .auto: "Auto"
        case .aperture: "Aperture"
        case .shutter: "Shutter"
        case .iso: "ISO"
        }
    }
}

private func previewViewModel(mode: ExposureMode) -> (MeterViewModel, MeterReadout) {
    let viewModel = MeterViewModel(sensor: SimulatedLightSensor(), smoother: EVSmoother()!, mode: mode, aperture: 4, shutterSpeed: 1.0 / 250)
    let ev = 14.97
    let priority: ExposurePriority = switch mode {
    case .auto: .aperture(5.6)
    case .aperture: .aperture(4)
    case .shutter: .shutter(1.0 / 250)
    case .iso: .iso(aperture: 4, shutter: 1.0 / 250)
    }
    let readout = MeterReadout(
        ev: ev,
        compensatedEV: ev,
        suggestion: ExposureSuggestion.suggestion(ev100: ev, baseISO: 100, priority: priority),
        equivalents: ExposureSuggestion.equivalents(ev100: ev, iso: 100)
    )
    return (viewModel, readout)
}

#Preview("Auto") {
    let (viewModel, readout) = previewViewModel(mode: .auto)

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        MeterPanel(viewModel: viewModel, readout: readout)
            .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Apertura") {
    let (viewModel, readout) = previewViewModel(mode: .aperture)

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        MeterPanel(viewModel: viewModel, readout: readout)
            .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("ISO") {
    let (viewModel, readout) = previewViewModel(mode: .iso)

    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        MeterPanel(viewModel: viewModel, readout: readout)
            .padding()
    }
    .preferredColorScheme(.dark)
}
