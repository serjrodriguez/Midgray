//
//  OnboardingView.swift
//  Midgray
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        VStack(spacing: 0) {
            topBar

            TabView(selection: $viewModel.index) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { offset, page in
                    OnboardingPageView(page: page)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            PageDots(count: viewModel.pages.count, current: viewModel.index)
                .padding(.bottom, verticalSizeClass == .compact ? Spacing.s8 : Spacing.s28)

            actions
                .padding(.horizontal, Spacing.s24)
                .padding(.bottom, verticalSizeClass == .compact ? Spacing.s4 : Spacing.s16)
        }
        .background(Color.black.ignoresSafeArea())
        .animation(.snappy, value: viewModel.index)
        .preferredColorScheme(.dark)
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished, viewModel.mode == .replay { dismiss() }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()

            Button("Skip") { viewModel.skip() }
                .opacity(viewModel.showsSkip ? 1 : 0)
                .disabled(!viewModel.showsSkip)
                .accessibilityHidden(!viewModel.showsSkip)
        }
        .frame(minHeight: Spacing.s40)
        .padding(.horizontal, Spacing.s24)
    }

    @ViewBuilder
    private var actions: some View {
        if viewModel.asksForCamera {
            VStack(spacing: Spacing.s12) {
                PrimaryActionButton(title: "Allow camera access", isProminent: true) {
                    Task { await viewModel.allowCamera() }
                }

                Button("Not now") { viewModel.notNow() }
                    .frame(minHeight: Spacing.s36)
            }
        } else {
            VStack(spacing: Spacing.s12) {
                PrimaryActionButton(title: viewModel.isLastPage ? "Done" : "Continue", isProminent: true) {
                    viewModel.next()
                }

                if verticalSizeClass != .compact {
                    Color.clear.frame(height: Spacing.s36)
                }
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var content: some View {
        VStack(spacing: Spacing.s24) {
            Spacer()

            if verticalSizeClass == .compact {
                HStack(spacing: Spacing.s24) {
                    illustration
                    texts
                }
            } else {
                illustration
                texts
            }

            Spacer()

            if verticalSizeClass != .compact {
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.s36)
    }

    private var illustration: some View {
        Image(systemName: page.symbol)
            .font(.system(size: 56))
            .foregroundStyle(Color.accentColor)
            .frame(width: 140, height: 140)
            .background(Color.meterWheelFill, in: RoundedRectangle(cornerRadius: Radius.r36))
            .accessibilityHidden(true)
    }

    private var texts: some View {
        VStack(spacing: Spacing.s12) {
            Text(page.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(page.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: Spacing.s8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.primary : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(current + 1) of \(count)")
    }
}

private extension OnboardingPage {
    var title: LocalizedStringKey {
        switch self {
        case .measure: "Measure the light of your scene"
        case .modes: "You choose, Midgray calculates"
        case .metering: "Average or spot"
        case .camera: "We need your camera"
        }
    }

    var message: LocalizedStringKey {
        switch self {
        case .measure: "Point your iPhone and Midgray works out the exposure for your camera."
        case .modes: "Set the aperture, shutter speed or ISO and the app calculates the other values."
        case .metering: "Measure the whole scene or tap a point to measure only that area."
        case .camera: "Midgray uses the camera only to measure the light. It does not save photos or send data."
        }
    }
}

#Preview("Primera") {
    OnboardingView(viewModel: OnboardingViewModel(mode: .firstLaunch))
}

#Preview("Permiso") {
    let viewModel = OnboardingViewModel(mode: .firstLaunch)
    viewModel.index = 3
    return OnboardingView(viewModel: viewModel)
}

#Preview("Repetición") {
    OnboardingView(viewModel: OnboardingViewModel(mode: .replay))
}
