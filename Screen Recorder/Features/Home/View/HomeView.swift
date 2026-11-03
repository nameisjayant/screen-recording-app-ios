import SwiftUI

/// Home shell: hosts the tab content above the custom `HomeBottomBar`.
struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let selectedTab = viewModel.state.selectedTab

        ZStack {
            AppBackground(glow: selectedTab.accent)

            Group {
                switch selectedTab {
                case .dashboard: DashboardView()
                case .recorder: RecorderView()
                case .settings: SettingsView()
                }
            }
            .id(selectedTab)
            .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
        .animation(.smooth(duration: 0.3), value: selectedTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HomeBottomBar(selectedTab: selectedTab) { viewModel.send(.selectTab($0)) }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
