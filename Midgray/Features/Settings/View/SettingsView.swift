//
//  SettingsView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                measurementSection
                helpSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        if viewModel.hasChanges { viewModel.save() }
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel.hasChanges)
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    private var measurementSection: some View {
        Section("Measurement") {
            NavigationLink {
                CalibrationView(viewModel: viewModel)
            } label: {
                SettingsRow(
                    title: "Calibration",
                    value: ExposureFormatter.compensation(viewModel.calibration),
                    symbol: "slider.horizontal.3"
                )
            }

            if viewModel.lenses.count > 1 {
                NavigationLink {
                    DefaultLensView(viewModel: viewModel)
                } label: {
                    SettingsRow(
                        title: "Default lens",
                        value: viewModel.defaultLens?.zoomLabel(),
                        symbol: "camera.aperture"
                    )
                }
            }
        }
    }

    private var helpSection: some View {
        Section("Help") {
            NavigationLink {
                HelpView()
            } label: {
                SettingsRow(title: "How to read the measurement", value: nil, symbol: "book")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            NavigationLink {
                PrivacyView()
            } label: {
                SettingsRow(title: "Privacy", value: nil, symbol: "hand.raised")
            }

            SettingsRow(title: "Version", value: viewModel.appInfo.versionDescription, symbol: "info.circle")
                .accessibilityElement(children: .combine)
        }
    }
}

private struct SettingsRow: View {
    let title: LocalizedStringKey
    let value: String?
    let symbol: String

    var body: some View {
        HStack(spacing: Spacing.s8) {
            Text(title)

            Spacer(minLength: Spacing.s8)

            if let value {
                Text(value)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Image(systemName: symbol)
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    let lenses = [
        CameraLens(id: "u", kind: .ultraWide, zoomFactor: 0.5),
        CameraLens(id: "w", kind: .wide, zoomFactor: 1),
        CameraLens(id: "t", kind: .telephoto, zoomFactor: 3)
    ]

    Color.black
        .sheet(isPresented: .constant(true)) {
            SettingsView(viewModel: SettingsViewModel(
                repository: InMemorySettingsRepository(MeterSettings(calibration: 0.3, defaultLensID: "w")),
                lenses: lenses,
                onSave: { _ in }
            ))
        }
}
