//
//  HelpView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct HelpView: View {
    private struct Topic: Identifiable {
        let id: String
        let title: LocalizedStringKey
        let body: LocalizedStringKey
    }

    private let topics: [Topic] = [
        Topic(id: "ev", title: "EV", body: "EV measures how much light there is in the scene. Higher numbers mean brighter light: around 15 on a sunny day, around 5 in a dim room."),
        Topic(id: "equivalents", title: "Equivalent exposures", body: "In Auto mode each chip is an aperture and shutter speed pair that lets in the same light. Tap one to use it."),
        Topic(id: "modes", title: "Exposure modes", body: "Aperture and Shutter keep the value you set and suggest the other. ISO suggests the sensitivity for the aperture and shutter speed you set."),
        Topic(id: "metering", title: "Metering", body: "Average measures the whole scene. Spot measures only the area around the point you tap on the screen. Switch between them with the viewfinder button."),
        Topic(id: "compensation", title: "Exposure compensation", body: "The ± button makes the suggestion brighter or darker than the reading, in steps of a third of a stop."),
        Topic(id: "range", title: "Out of range", body: "When the scene is too bright or too dark for the camera to measure reliably, Midgray warns you and the reading may be off."),
        Topic(id: "hold", title: "Hold", body: "Tap Measure to freeze the current reading. Tap again to keep measuring."),
        Topic(id: "calibration", title: "Calibration", body: "If Midgray reads differently from your camera or a hand-held meter, adjust it in Settings until they match.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s24) {
                ForEach(topics) { topic in
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text(topic.title)
                            .font(.headline)

                        Text(topic.body)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.s20)
            .padding(.top, Spacing.s12)
        }
        .background(Color.black)
        .navigationTitle("How to read the measurement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { HelpView() }
        .preferredColorScheme(.dark)
}
