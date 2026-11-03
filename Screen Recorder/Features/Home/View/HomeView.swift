import SwiftUI

/// Home shell: hosts the tab content above the custom `HomeBottomBar`, plus the recording setup dialog.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var settingsViewModel: SettingsViewModel

    init(viewModel: HomeViewModel, settingsViewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
        _settingsViewModel = State(initialValue: settingsViewModel)
    }

    var body: some View {
        let state = viewModel.state

        ZStack {
            AppBackground(glow: state.selectedTab.accent)

            Group {
                switch state.selectedTab {
                case .dashboard: DashboardView()
                case .settings: SettingsView(viewModel: settingsViewModel)
                }
            }
            .id(state.selectedTab)
            .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
        .animation(.smooth(duration: 0.3), value: state.selectedTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HomeBottomBar(selectedTab: state.selectedTab,
                          onSelect: { viewModel.send(.selectTab($0)) },
                          onRecord: { viewModel.send(.showRecordingSetup) })
        }
        .overlay { recordingSetup }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: state.isRecordingSetupPresented)
    }

    @ViewBuilder
    private var recordingSetup: some View {
        if viewModel.state.isRecordingSetupPresented {
            ZStack {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.send(.dismissRecordingSetup) }
                    .accessibilityHidden(true)
                    .transition(.opacity)

                RecordingSetupDialog(options: viewModel.state.recordingOptions,
                                     onFaceCamChange: { viewModel.send(.setFaceCamEnabled($0)) },
                                     onMicrophoneChange: { viewModel.send(.setMicrophoneEnabled($0)) },
                                     onStart: { viewModel.send(.startRecording) },
                                     onDismiss: { viewModel.send(.dismissRecordingSetup) })
                    .transition(.asymmetric(insertion: .scale(scale: 0.85).combined(with: .opacity),
                                            removal: .scale(scale: 0.95).combined(with: .opacity)))
            }
        }
    }
}

#Preview {
    let container = AppContainer.preview(hasCompletedOnboarding: true)
    HomeView(viewModel: container.makeHomeViewModel(), settingsViewModel: container.makeSettingsViewModel())
}
