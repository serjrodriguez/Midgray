//
//  MeterEquivalents.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import SwiftUI

struct MeterEquivalents: View {
    let viewModel: MeterViewModel
    var showsHeader = true

    var body: some View {
        if viewModel.mode == .auto, let readout {
            EquivalentsRow(
                equivalents: readout.equivalents,
                selectedAperture: readout.suggestion?.aperture,
                ev: readout.compensatedEV,
                showsHeader: showsHeader,
                headerHasBackground: true,
                onSelect: viewModel.selectAutoAperture
            )
        }
    }

    private var readout: MeterReadout? {
        switch viewModel.state {
        case .measuring(let readout), .outOfRange(let readout): readout
        case .idle, .failed: nil
        }
    }
}
