//
//  MeterToolbar.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct MeterToolbar: View {
    @Bindable var viewModel: MeterViewModel

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: Spacing.s8) {
                if viewModel.lenses.count > 1 {
                    LensButton(
                        lenses: viewModel.lenses,
                        selected: viewModel.selectedLens,
                        onSelect: viewModel.selectLens
                    )
                }

                CompensationButton(compensation: compensationBinding)
            }
        }
    }

    private var compensationBinding: Binding<Double> {
        Binding(
            get: { viewModel.compensation },
            set: { viewModel.setCompensation($0) }
        )
    }
}
