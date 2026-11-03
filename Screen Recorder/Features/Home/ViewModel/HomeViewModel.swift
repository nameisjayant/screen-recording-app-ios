import Observation

nonisolated struct HomeState: Equatable, Sendable {
    var selectedTab: HomeTab = .dashboard
    var isRecordingSetupPresented = false
    var recordingOptions = RecordingOptions()
    var recorder = RecorderState()
}

enum HomeIntent {
    case selectTab(HomeTab)
    case showRecordingSetup
    case dismissRecordingSetup
    case setFaceCamEnabled(Bool)
    case setMicrophoneEnabled(Bool)
    case startRecording
    case pauseRecording
    case resumeRecording
    case stopRecording
}

@Observable
final class HomeViewModel: ViewModel {
    private(set) var state: HomeState

    @ObservationIgnored private let preferences: AppPreferences
    @ObservationIgnored private let recorder: RecordingService

    init(initialTab: HomeTab = .dashboard,
         preferences: AppPreferences,
         recorder: RecordingService) {
        self.state = HomeState(selectedTab: initialTab,
                               recordingOptions: preferences.recordingOptions,
                               recorder: recorder.state)
        self.preferences = preferences
        self.recorder = recorder
        recorder.observeState { [weak self] recorderState in
            guard let self else { return false }
            self.state.recorder = recorderState
            return true
        }
    }

    func send(_ intent: HomeIntent) {
        switch intent {
        case .selectTab(let tab):
            state.selectedTab = tab
        case .showRecordingSetup:
            // One recording at a time; the status bar controls the running one.
            guard !state.recorder.status.isActive else { return }
            state.isRecordingSetupPresented = true
        case .dismissRecordingSetup:
            state.isRecordingSetupPresented = false
        case .setFaceCamEnabled(let isEnabled):
            updateOptions { $0.isFaceCamEnabled = isEnabled }
        case .setMicrophoneEnabled(let isEnabled):
            updateOptions { $0.isMicrophoneEnabled = isEnabled }
        case .startRecording:
            guard state.isRecordingSetupPresented else { return }
            state.isRecordingSetupPresented = false
            recorder.start(with: state.recordingOptions)
        case .pauseRecording:
            recorder.pause()
        case .resumeRecording:
            recorder.resume()
        case .stopRecording:
            recorder.stop()
        }
    }

    private func updateOptions(_ change: (inout RecordingOptions) -> Void) {
        change(&state.recordingOptions)
        preferences.recordingOptions = state.recordingOptions
    }
}
