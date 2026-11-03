import Foundation
import Testing
@testable import Screen_Recorder

@MainActor
struct HomeViewModelTests {
    private func makeViewModel(preferences: AppPreferences = InMemoryAppPreferences(),
                               recorder: FakeRecorder = FakeRecorder()) -> HomeViewModel {
        HomeViewModel(preferences: preferences, recorder: recorder)
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
        let recorder = FakeRecorder()
        let viewModel = makeViewModel(recorder: recorder)

        viewModel.send(.startRecording)
        #expect(recorder.started.isEmpty, "Start is ignored while the dialog is closed")

        viewModel.send(.showRecordingSetup)
        viewModel.send(.setFaceCamEnabled(true))
        viewModel.send(.startRecording)

        #expect(!viewModel.state.isRecordingSetupPresented)
        #expect(recorder.started == [RecordingOptions(isFaceCamEnabled: true, isMicrophoneEnabled: true)])
    }

    @Test func mirrorsRecorderStateAndForwardsControls() {
        let recorder = FakeRecorder()
        let viewModel = makeViewModel(recorder: recorder)
        let recording = RecorderState(status: .started(at: .now), isFaceCamOn: true)

        recorder.state = recording
        #expect(viewModel.state.recorder == recording)

        viewModel.send(.pauseRecording)
        viewModel.send(.resumeRecording)
        viewModel.send(.stopRecording)
        #expect(recorder.commands == ["pause", "resume", "stop"])

        recorder.state = RecorderState()
        #expect(viewModel.state.recorder == RecorderState())
    }

    @Test func setupDialogStaysClosedWhileRecording() {
        let recorder = FakeRecorder()
        recorder.state = RecorderState(status: .started(at: .now))
        let viewModel = makeViewModel(recorder: recorder)

        viewModel.send(.showRecordingSetup)
        #expect(!viewModel.state.isRecordingSetupPresented)
    }
}
