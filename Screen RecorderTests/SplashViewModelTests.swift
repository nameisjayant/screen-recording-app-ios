import Testing
@testable import Screen_Recorder

@MainActor
struct SplashViewModelTests {
    @Test func playsTimelineThenFinishesOnce() async {
        var finishCount = 0
        let viewModel = SplashViewModel(environment: .prod, sleep: { _ in }, onFinish: { finishCount += 1 })

        await viewModel.start()
        await viewModel.start()

        #expect(viewModel.state.phase == .finished)
        #expect(finishCount == 1)
    }

    @Test func skipIsIgnoredBeforeTitleAppears() {
        var finished = false
        let viewModel = SplashViewModel(environment: .prod, sleep: { _ in }, onFinish: { finished = true })

        viewModel.send(.skipRequested)

        #expect(!finished)
        #expect(viewModel.state.phase == .idle)
    }

    @Test func showsBetaBadgeOnlyInBeta() {
        #expect(SplashViewModel(environment: .beta, onFinish: {}).state.showsBetaBadge)
        #expect(!SplashViewModel(environment: .prod, onFinish: {}).state.showsBetaBadge)
    }
}
