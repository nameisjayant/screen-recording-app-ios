import Foundation

/// Messages sent between the app (and its Live Activity buttons) and the broadcast extension.
nonisolated enum RecordingEvent: String, CaseIterable, Sendable {
    /// App → extension.
    case pause
    case resume
    case stop
    /// Extension → app: `RecordingChannel.status` changed.
    case statusChanged
}

/// Talks across the app / extension process boundary: state lives in the shared App Group defaults,
/// and Darwin notifications ping the other side when something changes.
nonisolated struct RecordingChannel: Sendable {
    private enum Key {
        static let status = "recording.status"
        static let isMicrophoneEnabled = "recording.isMicrophoneEnabled"
    }

    let appGroupIdentifier: String

    /// Reads the App Group from the running target's Info.plist (`AppGroupIdentifier`), which the xcconfigs set per flavor.
    init(appGroupIdentifier: String = Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String ?? "") {
        self.appGroupIdentifier = appGroupIdentifier
    }

    private var defaults: UserDefaults? { UserDefaults(suiteName: appGroupIdentifier) }

    var status: RecordingStatus {
        get {
            guard let data = defaults?.data(forKey: Key.status),
                  let status = try? JSONDecoder().decode(RecordingStatus.self, from: data) else { return .idle }
            return status
        }
        nonmutating set {
            defaults?.set(try? JSONEncoder().encode(newValue), forKey: Key.status)
        }
    }

    /// The app's microphone choice, so the extension knows whether to keep the mic audio it receives.
    var isMicrophoneEnabled: Bool {
        get { defaults?.object(forKey: Key.isMicrophoneEnabled) as? Bool ?? true }
        nonmutating set { defaults?.set(newValue, forKey: Key.isMicrophoneEnabled) }
    }

    /// Where finished recordings are saved, inside the shared container.
    var recordingsDirectory: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appending(path: "Recordings", directoryHint: .isDirectory)
    }

    // MARK: - Darwin notifications

    func post(_ event: RecordingEvent) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             CFNotificationName(notificationName(for: event) as CFString),
                                             nil, nil, true)
    }

    /// Calls `handler` every time `event` is posted, until the returned observation is released.
    func observe(_ event: RecordingEvent, handler: @escaping @Sendable () -> Void) -> DarwinObservation {
        DarwinObservation(name: notificationName(for: event), handler: handler)
    }

    /// Polls the shared status until `condition` holds or `timeout` passes, then returns the latest status.
    func waitForStatus(timeout: Duration = .seconds(2),
                       where condition: (RecordingStatus) -> Bool) async -> RecordingStatus {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        var latest = status
        while !condition(latest), clock.now < deadline {
            try? await Task.sleep(for: .milliseconds(100))
            latest = status
        }
        return latest
    }

    private func notificationName(for event: RecordingEvent) -> String {
        "\(appGroupIdentifier).recording.\(event.rawValue)"
    }
}

/// A live Darwin notification observer; removed from the notify center when released.
nonisolated final class DarwinObservation: Sendable {
    private let name: String
    private let handler: @Sendable () -> Void

    fileprivate init(name: String, handler: @escaping @Sendable () -> Void) {
        self.name = name
        self.handler = handler
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        Unmanaged.passUnretained(self).toOpaque(),
                                        { _, observer, _, _, _ in
                                            guard let observer else { return }
                                            Unmanaged<DarwinObservation>.fromOpaque(observer).takeUnretainedValue().handler()
                                        },
                                        name as CFString,
                                        nil,
                                        .deliverImmediately)
    }

    deinit {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                           Unmanaged.passUnretained(self).toOpaque(),
                                           CFNotificationName(name as CFString),
                                           nil)
    }
}
