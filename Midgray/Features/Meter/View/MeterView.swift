//
//  MeterView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct MeterView: View {
    @State private var viewModel: MeterViewModel

    init(viewModel: MeterViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack {
            switch viewModel.state {
                case .idle: Text("Midiendo...")
                case .measuring(let readout):
                    VStack {
                        Text(readout.ev.description)
                        Text(readout.compensatedEV.description)
                    }
                case .outOfRange(let readout):
                    Text("Out of range")
            }
        }
        .task {
            viewModel.start()
        }
        .onDisappear() {
            viewModel.stop()
        }
    }
}

#Preview {
    let smoother = EVSmoother()!
    MeterView(viewModel: MeterViewModel(sensor: SimulatedLightSensor(), smoother: smoother))
}
