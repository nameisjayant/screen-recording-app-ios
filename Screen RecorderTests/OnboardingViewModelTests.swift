import Testing
@testable import Screen_Recorder

@MainActor
struct OnboardingViewModelTests {
    @Test func startsOnFirstPage() {
        let viewModel = OnboardingViewModel(onFinish: {})

        #expect(viewModel.state.currentIndex == 0)
        #expect(viewModel.state.currentPage.kind == .screenRecording)
        #expect(!viewModel.state.isLastPage)
    }

    @Test func nextAndSwipeMoveBetweenPages() {
        let viewModel = OnboardingViewModel(onFinish: {})

        viewModel.send(.next)
        #expect(viewModel.state.currentIndex == 1)

        viewModel.send(.selectPage(0))
        #expect(viewModel.state.currentIndex == 0)
    }

    @Test func nextOnLastPageFinishesOnce() {
        var finishCount = 0
        let viewModel = OnboardingViewModel(onFinish: { finishCount += 1 })

        viewModel.send(.next)
        viewModel.send(.next)
        #expect(viewModel.state.isLastPage)
        viewModel.send(.next)
        viewModel.send(.next)

        #expect(finishCount == 1)
    }

    @Test func skipFinishesImmediately() {
        var finished = false
        let viewModel = OnboardingViewModel(onFinish: { finished = true })

        viewModel.send(.skip)

        #expect(finished)
    }

    @Test func ignoresOutOfRangeSelection() {
        let viewModel = OnboardingViewModel(onFinish: {})

        viewModel.send(.selectPage(42))

        #expect(viewModel.state.currentIndex == 0)
    }
}
