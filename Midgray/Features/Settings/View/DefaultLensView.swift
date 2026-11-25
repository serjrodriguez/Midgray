//
//  DefaultLensView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct DefaultLensView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {
                ForEach(viewModel.lenses.reversed()) { lens in
                    Button {
                        viewModel.selectDefaultLens(lens)
                    } label: {
                        HStack {
                            Text(lens.title)
                                .foregroundStyle(Color.primary)

                            Spacer()

                            if lens == viewModel.defaultLens {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .accessibilityAddTraits(lens == viewModel.defaultLens ? .isSelected : [])
                }
            } footer: {
                Text("Midgray starts with this lens.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .navigationTitle("Default lens")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DefaultLensView(viewModel: SettingsViewModel(
            repository: InMemorySettingsRepository(),
            lenses: [
                CameraLens(id: "u", kind: .ultraWide, zoomFactor: 0.5),
                CameraLens(id: "w", kind: .wide, zoomFactor: 1),
                CameraLens(id: "t", kind: .telephoto, zoomFactor: 3)
            ],
            onSave: { _ in }
        ))
    }
    .preferredColorScheme(.dark)
}
