import Observation

nonisolated struct HomeState: Equatable, Sendable {
    var selectedTab: HomeTab = .dashboard
}

enum HomeIntent {
    case selectTab(HomeTab)
}

@Observable
final class HomeViewModel: ViewModel {
    private(set) var state: HomeState

    init(initialTab: HomeTab = .dashboard) {
        self.state = HomeState(selectedTab: initialTab)
    }

    func send(_ intent: HomeIntent) {
        switch intent {
        case .selectTab(let tab):
            state.selectedTab = tab
        }
    }
}
