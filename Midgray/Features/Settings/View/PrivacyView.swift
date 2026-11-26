//
//  PrivacyView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                Text("Midgray uses the camera only to measure the light of a scene. It never saves photos or videos.")
                Text("Nothing is sent anywhere: Midgray has no accounts and collects no data.")
                Text("Your settings, such as calibration and default lens, are stored only on this iPhone.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.s20)
            .padding(.top, Spacing.s12)
        }
        .background(Color.black)
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { PrivacyView() }
        .preferredColorScheme(.dark)
}
