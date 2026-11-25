//
//  MeteringButton.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 25/11/26.
//

import SwiftUI

struct MeteringButton: View {
    let mode: MeteringMode
    let onSelect: (MeteringMode) -> Void

    var body: some View {
        Menu {
            ForEach(MeteringMode.allCases, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    if option == mode {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        } label: {
            Image(systemName: mode.symbol)
        }
        .accessibilityLabel("Metering")
        .accessibilityValue(mode.title)
    }
}

extension MeteringMode {
    var title: LocalizedStringKey {
        switch self {
        case .average: "Average"
        case .spot: "Spot"
        }
    }

    var symbol: String {
        switch self {
        case .average: "viewfinder"
        case .spot: "dot.viewfinder"
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        NavigationStack {
            Color.clear
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        MeteringButton(mode: .spot, onSelect: { _ in })
                    }
                }
        }
    }
    .preferredColorScheme(.dark)
}
