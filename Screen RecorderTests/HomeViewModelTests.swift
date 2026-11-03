import Testing
@testable import Screen_Recorder

@MainActor
struct HomeViewModelTests {
    @Test func startsOnDashboard() {
        let viewModel = HomeViewModel()

        #expect(viewModel.state.selectedTab == .dashboard)
    }

    @Test func selectTabSwitchesTabs() {
        let viewModel = HomeViewModel()

        viewModel.send(.selectTab(.recorder))
        #expect(viewModel.state.selectedTab == .recorder)

        viewModel.send(.selectTab(.settings))
        #expect(viewModel.state.selectedTab == .settings)

        viewModel.send(.selectTab(.dashboard))
        #expect(viewModel.state.selectedTab == .dashboard)
    }
}
