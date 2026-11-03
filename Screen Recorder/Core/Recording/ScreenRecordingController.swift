import UIKit

/// Live `RecordingService`. The recording itself runs in the RecQuestBroadcast extension, so it keeps going
/// when RecQuest is in the background or closed; this class starts it, sends it commands, mirrors its
/// status, and keeps the Live Activity and face cam in step.
final class ScreenRecordingController: RecordingService {
    private(set) var state = RecorderState() {
        didSet {
            guard state != oldValue else { return }
            observers = observers.filter { $0(state) }
        }
    }
    private var observers: [(RecorderState) -> Bool] = []

    let faceCam: FaceCamController

    private let channel: RecordingChannel
    private let preferences: AppPreferences
    private let picker = BroadcastPickerLauncher()
    /// Options of the current (or next) recording.
    private var options: RecordingOptions
    private var isStartPending = false
    private var statusObservation: DarwinObservation?
    /// Lives as long as the controller, which lives as long as the app.
    private var activeObserver: NSObjectProtocol?
    private var liveActivityTask: Task<Void, Never>?

    init(preferences: AppPreferences,
         channel: RecordingChannel = RecordingChannel(),
         faceCam: FaceCamController = FaceCamController()) {
        self.preferences = preferences
        self.channel = channel
        self.faceCam = faceCam
        self.options = preferences.recordingOptions

        statusObservation = channel.observe(.statusChanged) { [weak self] in
            Task { @MainActor in self?.refresh() }
        }
        // Catch up on anything that happened while suspended (e.g. stopped from Control Center).
        activeObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                                object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }

    func observeState(_ observer: @escaping (RecorderState) -> Bool) {
        observers.append(observer)
    }

    func start(with options: RecordingOptions) {
        guard !state.status.isActive else { return }
        self.options = options
        isStartPending = true
        channel.isMicrophoneEnabled = options.isMicrophoneEnabled
        Task {
            if options.isFaceCamEnabled {
                // Ask before the broadcast sheet so the two prompts don't overlap.
                _ = await faceCam.requestAccess()
            }
            picker.present(showsMicrophoneButton: options.isMicrophoneEnabled)
        }
    }

    func pause() { channel.post(.pause) }
    func resume() { channel.post(.resume) }
    func stop() { channel.post(.stop) }

    private func refresh() {
        var status = channel.status
        if status.isStale(at: .now) {
            status = .idle
            channel.status = .idle
        }
        if !state.status.isActive, status.isActive {
            // Started from Control Center rather than the setup dialog: use the last saved choices.
            if !isStartPending { options = preferences.recordingOptions }
            isStartPending = false
        }

        let isFaceCamOn = status.isActive && options.isFaceCamEnabled && faceCam.isAuthorized
        if isFaceCamOn { faceCam.start() } else { faceCam.stop() }
        state = RecorderState(status: status, isFaceCamOn: isFaceCamOn)
        syncLiveActivity(with: status)
    }

    private func syncLiveActivity(with status: RecordingStatus) {
        // A new Live Activity can only be started while RecQuest is in the foreground.
        let attributes = UIApplication.shared.applicationState == .active
            ? RecordingActivityAttributes(isMicrophoneEnabled: options.isMicrophoneEnabled,
                                          isFaceCamEnabled: options.isFaceCamEnabled)
            : nil
        let previous = liveActivityTask
        liveActivityTask = Task {
            await previous?.value
            await RecordingLiveActivity.sync(with: status, attributes: attributes)
        }
    }
}
