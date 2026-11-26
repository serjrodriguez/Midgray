//
//  MeterViewfinder.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 26/11/26.
//

import SwiftUI
import AVFoundation

struct MeterViewfinder: View {
    let viewModel: MeterViewModel
    let previewSession: AVCaptureSession?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let previewSession {
                    CameraPreview(
                        session: previewSession,
                        configuration: "\(viewModel.selectedLens?.id ?? "")-\(viewModel.isSwitchingLens)-\(viewModel.hasReading)",
                        onTap: handleSpotTap
                    )
                        .opacity(viewModel.isSwitchingLens ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isSwitchingLens)
                } else {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            let point = CGPoint(x: location.x / geometry.size.width, y: location.y / geometry.size.height)
                            handleSpotTap(viewPoint: point, devicePoint: point)
                        }
                }

                if viewModel.meteringMode == .spot, viewModel.hasReading {
                    SpotReticle()
                        .position(x: viewModel.spot.x * geometry.size.width, y: viewModel.spot.y * geometry.size.height)
                        .animation(.snappy, value: viewModel.spot)
                }
            }
            .onChange(of: geometry.size) {
                viewModel.resetSpot()
            }
        }
        .ignoresSafeArea()
    }

    private func handleSpotTap(viewPoint: CGPoint, devicePoint: CGPoint) {
        viewModel.setSpot(viewPoint: viewPoint, devicePoint: devicePoint)
    }
}
