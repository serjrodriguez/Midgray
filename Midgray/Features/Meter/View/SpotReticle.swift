//
//  SpotReticle.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 25/11/26.
//

import SwiftUI

struct SpotReticle: View {
    private static let size: CGFloat = 72

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.white, lineWidth: 2)
                .frame(width: Self.size, height: Self.size)

            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
        }
        .shadow(color: .black.opacity(0.5), radius: 3)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
        SpotReticle()
    }
}
