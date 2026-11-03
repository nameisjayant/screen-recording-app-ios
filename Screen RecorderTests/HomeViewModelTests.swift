import Testing
@testable import Screen_Recorder

@MainActor
struct HomeViewModelTests {
    private func makeViewModel(preferences: AppPreferences = InMemoryAppPreferences(),
                               onStartRecording: @escaping (RecordingOptions) -> Void = { _ in }) -> HomeViewModel {
        HomeViewModel(preferences: preferences, onStartRecording: onStartRecording)
    }

    @Test func startsOnDashboardWithDialogClosed() {
        let viewModel = makeViewModel()

        #expect(viewModel.state.selectedTab == .dashboard)
        #expect(!viewModel.state.isRecordingSetupPresented)
    }

    @Test func selectTabSwitchesTabs() {
        let viewModel = makeViewModel()

        viewModel.send(.selectTab(.settings))
        #expect(viewModel.state.selectedTab == .settings)

        viewModel.send(.selectTab(.dashboard))
        #expect(viewModel.state.selectedTab == .dashboard)
    }

    @Test func recordButtonOpensDialogWithoutChangingTab() {
        let viewModel = makeViewModel()
        viewModel.send(.selectTab(.settings))

        viewModel.send(.showRecordingSetup)
        #expect(viewModel.state.isRecordingSetupPresented)
        #expect(viewModel.state.selectedTab == .settings)

        viewModel.send(.dismissRecordingSetup)
        #expect(!viewModel.state.isRecordingSetupPresented)
    }

    @Test func optionsLoadFromAndSaveToPreferences() {
        let preferences = InMemoryAppPreferences(
            recordingOptions: RecordingOptions(isFaceCamEnabled: true, isMicrophoneEnabled: false))
        let viewModel = makeViewModel(preferences: preferences)
        #expect(viewModel.state.recordingOptions == preferences.recordingOptions)

        viewModel.send(.setFaceCamEnabled(false))
        viewModel.send(.setMicrophoneEnabled(true))

        let expected = RecordingOptions(isFaceCamEnabled: false, isMicrophoneEnabled: true)
        #expect(viewModel.state.recordingOptions == expected)
        #expect(preferences.recordingOptions == expected)
    }

    @Test func startRecordingClosesDialogAndPassesOptions() {
        var started: [RecordingOptions] = []
        let viewModel = makeViewModel(onStartRecording: { started.append($0) })

        viewModel.send(.startRecording)
        #expect(started.isEmpty, "Start is ignored while the dialog is closed")

        viewModel.send(.showRecordingSetup)
        viewModel.send(.setFaceCamEnabled(true))
        viewModel.send(.startRecording)

        #expect(!viewModel.state.isRecordingSetupPresented)
        #expect(started == [RecordingOptions(isFaceCamEnabled: true, isMicrophoneEnabled: true)])
    }
}
