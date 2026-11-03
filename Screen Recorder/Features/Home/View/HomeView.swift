import AVFoundation
import SwiftUI

/// Home shell: hosts the tab content above the custom `HomeBottomBar`, plus the recording setup dialog,
/// the status bar of a running recording and the face cam bubble.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var dashboardViewModel: DashboardViewModel
    @State private var settingsViewModel: SettingsViewModel
    private let faceCamLayer: AVSampleBufferDisplayLayer?

    init(viewModel: HomeViewModel,
         dashboardViewModel: DashboardViewModel,
         settingsViewModel: SettingsViewModel,
         faceCamLayer: AVSampleBufferDisplayLayer? = nil) {
        _viewModel = State(initialValue: viewModel)
        _dashboardViewModel = State(initialValue: dashboardViewModel)
        _settingsViewModel = State(initialValue: settingsViewModel)
        self.faceCamLayer = faceCamLayer
    }

    var body: some View {
        let state = viewModel.state

        ZStack {
            AppBackground(glow: state.selectedTab.accent)

            Group {
                switch state.selectedTab {
                case .dashboard: DashboardView(viewModel: dashboardViewModel)
                case .settings: SettingsView(viewModel: settingsViewModel)
                }
            }
            .id(state.selectedTab)
            .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
        .animation(.smooth(duration: 0.3), value: state.selectedTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: Spacing.s) {
                if state.recorder.status.isActive {
                    RecordingStatusBar(status: state.recorder.status,
                                       onPause: { viewModel.send(.pauseRecording) },
                                       onResume: { viewModel.send(.resumeRecording) },
                                       onStop: { viewModel.send(.stopRecording) })
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                HomeBottomBar(selectedTab: state.selectedTab,
                              onSelect: { viewModel.send(.selectTab($0)) },
                              onRecord: { viewModel.send(.showRecordingSetup) })
            }
        }
        .overlay(alignment: .topTrailing) { faceCam }
        .overlay { recordingSetup }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: state.isRecordingSetupPresented)
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: state.recorder)
    }

    @ViewBuilder
    private var faceCam: some View {
        if viewModel.state.recorder.isFaceCamOn, let faceCamLayer {
            LiveFaceCamBubble(layer: faceCamLayer)
                .padding(Spacing.m)
                .transition(.scale.combined(with: .opacity))
        }
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
    HomeView(viewModel: container.makeHomeViewModel(),
             dashboardViewModel: container.makeDashboardViewModel(),
             settingsViewModel: container.makeSettingsViewModel())
}
