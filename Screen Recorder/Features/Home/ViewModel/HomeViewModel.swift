import Observation

nonisolated struct HomeState: Equatable, Sendable {
    var selectedTab: HomeTab = .dashboard
    var isRecordingSetupPresented = false
    var recordingOptions = RecordingOptions()
}

enum HomeIntent {
    case selectTab(HomeTab)
    case showRecordingSetup
    case dismissRecordingSetup
    case setFaceCamEnabled(Bool)
    case setMicrophoneEnabled(Bool)
    case startRecording
}

@Observable
final class HomeViewModel: ViewModel {
    private(set) var state: HomeState

    @ObservationIgnored private let preferences: AppPreferences
    @ObservationIgnored private let onStartRecording: (RecordingOptions) -> Void

    init(initialTab: HomeTab = .dashboard,
         preferences: AppPreferences,
         onStartRecording: @escaping (RecordingOptions) -> Void) {
        self.state = HomeState(selectedTab: initialTab, recordingOptions: preferences.recordingOptions)
        self.preferences = preferences
        self.onStartRecording = onStartRecording
    }

    func send(_ intent: HomeIntent) {
        switch intent {
        case .selectTab(let tab):
            state.selectedTab = tab
        case .showRecordingSetup:
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
            onStartRecording(state.recordingOptions)
        }
    }

    private func updateOptions(_ change: (inout RecordingOptions) -> Void) {
        change(&state.recordingOptions)
        preferences.recordingOptions = state.recordingOptions
    }
}
