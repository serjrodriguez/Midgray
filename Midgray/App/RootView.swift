//
//  RootView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI
import AVFoundation

struct RootView: View {
    @State private var permissions: CameraPermissionsViewModel
    @State private var onboarding: OnboardingViewModel?
    let meter: MeterViewModel
    let previewSession: AVCaptureSession?
    let settings: any SettingsRepository
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    init(permissions: CameraPermissionsViewModel,
         meter: MeterViewModel,
         previewSession: AVCaptureSession? = nil,
         settings: any SettingsRepository = InMemorySettingsRepository(),
         onboardingRepository: any OnboardingRepository = InMemoryOnboardingRepository(completed: true)) {
        _permissions = State(initialValue: permissions)
        _onboarding = State(initialValue: onboardingRepository.hasCompleted ? nil : OnboardingViewModel(
            mode: .firstLaunch,
            requestCamera: { await permissions.request() },
            onFinish: { onboardingRepository.markCompleted() }
        ))
        self.meter = meter
        self.previewSession = previewSession
        self.settings = settings
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let onboarding, !onboarding.isFinished {
                OnboardingView(viewModel: onboarding)
            } else if permissions.access == .granted {
                MeterView(viewModel: meter,
                          previewSession: previewSession,
                          settings: settings)
            } else {
                CameraAccessView(
                    access: permissions.access,
                    onRequest: { Task { await permissions.request() } },
                    onOpenSettings: openSettings
                )
            }
        }
        .preferredColorScheme(.dark)
        .task { await permissions.refresh() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await permissions.refresh() }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
