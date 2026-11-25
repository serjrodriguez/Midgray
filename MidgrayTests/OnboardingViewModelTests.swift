//
//  OnboardingViewModelTests.swift
//  MidgrayTests
//
//  Created by Sergio Rodriguez on 24/11/26.
//

import Testing
@testable import Midgray

@MainActor
struct OnboardingViewModelTests {
    final class Probe {
        var cameraRequests = 0
        var finishes = 0
    }

    func makeViewModel(mode: OnboardingMode) -> (OnboardingViewModel, Probe) {
        let probe = Probe()
        let viewModel = OnboardingViewModel(
            mode: mode,
            requestCamera: { probe.cameraRequests += 1 },
            onFinish: { probe.finishes += 1 }
        )
        return (viewModel, probe)
    }

    @Test
    func firstLaunchHasFourPagesEndingWithTheCamera() {
        let (viewModel, _) = makeViewModel(mode: .firstLaunch)
        #expect(viewModel.pages == [.measure, .modes, .adjust, .camera])
    }

    @Test
    func replayLeavesOutTheCameraPage() {
        let (viewModel, _) = makeViewModel(mode: .replay)
        #expect(viewModel.pages == [.measure, .modes, .adjust])
    }

    @Test
    func startsOnTheFirstPage() {
        let (viewModel, _) = makeViewModel(mode: .firstLaunch)

        #expect(viewModel.currentPage == .measure)
        #expect(!viewModel.isLastPage)
        #expect(viewModel.showsSkip)
        #expect(!viewModel.asksForCamera)
    }

    @Test
    func nextAdvancesOnePageAtATime() {
        let (viewModel, probe) = makeViewModel(mode: .firstLaunch)

        viewModel.next()
        #expect(viewModel.currentPage == .modes)

        viewModel.next()
        #expect(viewModel.currentPage == .adjust)

        #expect(probe.finishes == 0)
        #expect(!viewModel.isFinished)
    }

    @Test
    func skipJumpsToTheCameraPageOnFirstLaunch() {
        let (viewModel, probe) = makeViewModel(mode: .firstLaunch)

        viewModel.skip()

        #expect(viewModel.currentPage == .camera)
        #expect(viewModel.asksForCamera)
        #expect(!viewModel.showsSkip)
        #expect(probe.finishes == 0)
    }

    @Test
    func skipClosesTheTutorialOnReplay() {
        let (viewModel, probe) = makeViewModel(mode: .replay)

        viewModel.skip()

        #expect(viewModel.isFinished)
        #expect(probe.finishes == 1)
    }

    @Test
    func nextOnTheLastReplayPageFinishes() {
        let (viewModel, probe) = makeViewModel(mode: .replay)

        viewModel.next()
        viewModel.next()
        #expect(viewModel.isLastPage)
        #expect(!viewModel.showsSkip)

        viewModel.next()

        #expect(viewModel.isFinished)
        #expect(probe.finishes == 1)
    }

    @Test
    func allowingTheCameraRequestsAccessAndFinishes() async {
        let (viewModel, probe) = makeViewModel(mode: .firstLaunch)
        viewModel.skip()

        await viewModel.allowCamera()

        #expect(probe.cameraRequests == 1)
        #expect(probe.finishes == 1)
        #expect(viewModel.isFinished)
    }

    @Test
    func allowingTheCameraIsIgnoredBeforeTheCameraPage() async {
        let (viewModel, probe) = makeViewModel(mode: .firstLaunch)

        await viewModel.allowCamera()

        #expect(probe.cameraRequests == 0)
        #expect(!viewModel.isFinished)
    }

    @Test
    func notNowFinishesWithoutRequestingAccess() {
        let (viewModel, probe) = makeViewModel(mode: .firstLaunch)
        viewModel.skip()

        viewModel.notNow()

        #expect(probe.cameraRequests == 0)
        #expect(probe.finishes == 1)
        #expect(viewModel.isFinished)
    }

    @Test
    func notNowIsIgnoredBeforeTheCameraPage() {
        let (viewModel, probe) = makeViewModel(mode: .firstLaunch)

        viewModel.notNow()

        #expect(probe.finishes == 0)
        #expect(!viewModel.isFinished)
    }

    @Test
    func finishingTwiceNotifiesOnce() async {
        let (viewModel, probe) = makeViewModel(mode: .firstLaunch)
        viewModel.skip()

        await viewModel.allowCamera()
        await viewModel.allowCamera()
        viewModel.notNow()
        viewModel.next()

        #expect(probe.finishes == 1)
        #expect(probe.cameraRequests == 1)
    }

    @Test(arguments: [-5, 99])
    func anOutOfRangeIndexStillResolvesToAPage(index: Int) {
        let (viewModel, _) = makeViewModel(mode: .firstLaunch)

        viewModel.index = index

        #expect(viewModel.pages.contains(viewModel.currentPage))
    }
}
