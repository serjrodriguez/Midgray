//
//  CalibrationView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct CalibrationView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.s24) {
                Text("Compare the reading with your light meter or camera and adjust until they match.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                card

                PrimaryActionButton(title: "Reset to 0.0 EV", isProminent: false, action: viewModel.resetCalibration)
                    .disabled(!viewModel.canResetCalibration)
                    .opacity(viewModel.canResetCalibration ? 1 : 0.6)

                Text("The adjustment is saved on your iPhone and applied to every measurement.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.s20)
            .padding(.top, Spacing.s12)
        }
        .background(Color.black)
        .navigationTitle("Calibration")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var card: some View {
        VStack(spacing: Spacing.s12) {
            Text(ExposureFormatter.compensation(viewModel.calibration))
                .font(.system(size: 40, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: viewModel.calibration)

            Text("Current adjustment")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                stepButton(symbol: "minus", label: "Decrease adjustment", steps: -1, isEnabled: viewModel.canDecreaseCalibration)

                Divider()
                    .frame(height: Spacing.s20)

                stepButton(symbol: "plus", label: "Increase adjustment", steps: 1, isEnabled: viewModel.canIncreaseCalibration)
            }
            .glassEffect(.regular, in: .capsule)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.s28)
        .background(Color.meterWheelFill, in: RoundedRectangle(cornerRadius: Radius.r26))
        .accessibilityElement(children: .contain)
        .accessibilityValue(ExposureFormatter.compensation(viewModel.calibration))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: viewModel.adjustCalibration(by: 1)
            case .decrement: viewModel.adjustCalibration(by: -1)
            @unknown default: break
            }
        }
    }

    private func stepButton(symbol: String, label: LocalizedStringKey, steps: Int, isEnabled: Bool) -> some View {
        Button {
            viewModel.adjustCalibration(by: steps)
        } label: {
            Image(systemName: symbol)
                .font(.body.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: Spacing.s40 + Spacing.s8, height: Spacing.s36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .buttonRepeatBehavior(.enabled)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
        .accessibilityLabel(label)
    }
}

#Preview {
    NavigationStack {
        CalibrationView(viewModel: SettingsViewModel(
            repository: InMemorySettingsRepository(MeterSettings(calibration: 0.3, defaultLensID: nil)),
            lenses: [],
            onSave: { _ in }
        ))
    }
    .preferredColorScheme(.dark)
}
