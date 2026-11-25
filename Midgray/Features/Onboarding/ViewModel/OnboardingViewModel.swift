//
//  OnboardingViewModel.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Foundation
import Observation

nonisolated enum OnboardingMode: Sendable {
    case firstLaunch
    case replay
}

@Observable
final class OnboardingViewModel {
    var index = 0
    private(set) var isFinished = false

    let mode: OnboardingMode
    let pages: [OnboardingPage]

    private let requestCamera: () async -> Void
    private let onFinish: () -> Void

    init(mode: OnboardingMode,
         requestCamera: @escaping () async -> Void = {},
         onFinish: @escaping () -> Void = {}) {
        self.mode = mode
        self.requestCamera = requestCamera
        self.onFinish = onFinish

        switch mode {
        case .firstLaunch: pages = [.measure, .modes, .adjust, .camera]
        case .replay: pages = [.measure, .modes, .adjust]
        }
    }

    var currentPage: OnboardingPage {
        pages[min(max(index, 0), pages.count - 1)]
    }

    var isLastPage: Bool {
        index >= pages.count - 1
    }

    var showsSkip: Bool {
        !isLastPage
    }

    var asksForCamera: Bool {
        currentPage == .camera
    }

    func next() {
        guard !isFinished else { return }

        if isLastPage {
            finish()
        } else {
            index += 1
        }
    }

    func skip() {
        guard !isFinished else { return }

        switch mode {
        case .firstLaunch: index = pages.count - 1
        case .replay: finish()
        }
    }

    func allowCamera() async {
        guard asksForCamera, !isFinished else { return }

        await requestCamera()
        finish()
    }

    func notNow() {
        guard asksForCamera else { return }
        finish()
    }

    private func finish() {
        guard !isFinished else { return }

        isFinished = true
        onFinish()
    }
}

extension OnboardingViewModel: Hashable {
    nonisolated static func == (lhs: OnboardingViewModel, rhs: OnboardingViewModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
