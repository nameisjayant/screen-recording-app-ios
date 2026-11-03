import AppIntents

/// Live Activity buttons. `LiveActivityIntent`s run in the app's process (iOS wakes it if needed),
/// which forwards the command to the broadcast extension and refreshes the Live Activity.
struct PauseRecordingIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Pause Recording"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        await RecordingRemote.send(.pause) { $0.phase != .recording }
        return .result()
    }
}

struct ResumeRecordingIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Resume Recording"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        await RecordingRemote.send(.resume) { $0.phase != .paused }
        return .result()
    }
}

struct StopRecordingIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop Recording"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        await RecordingRemote.send(.stop) { !$0.isActive }
        return .result()
    }
}

nonisolated enum RecordingRemote {
    /// Sends `command` to the extension, waits until the shared status reflects it, then syncs the Live Activity.
    static func send(_ command: RecordingEvent,
                     channel: RecordingChannel = RecordingChannel(),
                     until isApplied: @escaping (RecordingStatus) -> Bool) async {
        var status = channel.status
        if status.isStale(at: .now) {
            status = .idle
            channel.status = status
        } else if status.isActive {
            channel.post(command)
            status = await channel.waitForStatus(where: isApplied)
        }
        await RecordingLiveActivity.sync(with: status)
    }
}
