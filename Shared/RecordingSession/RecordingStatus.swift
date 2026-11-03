import Foundation

/// What the broadcast extension is doing right now. Written by the extension, read by the app and the Live Activity.
nonisolated struct RecordingStatus: Codable, Equatable, Sendable {
    enum Phase: String, Codable, Sendable {
        case idle
        case recording
        case paused
    }

    var phase: Phase = .idle
    /// When recording began, pushed forward by every pause, so `now - startedAt` is the length recorded so far.
    var startedAt: Date?
    var pausedAt: Date?
    /// Refreshed every few seconds by the running extension; an old heartbeat means the extension is gone.
    var heartbeatAt: Date?

    static let idle = RecordingStatus()

    static func started(at date: Date) -> RecordingStatus {
        RecordingStatus(phase: .recording, startedAt: date, pausedAt: nil, heartbeatAt: date)
    }

    var isActive: Bool { phase != .idle }

    func elapsed(at date: Date) -> TimeInterval {
        guard let startedAt else { return 0 }
        return max(0, (pausedAt ?? date).timeIntervalSince(startedAt))
    }

    /// True when the extension stopped sending heartbeats (killed or crashed) without resetting the status.
    func isStale(at date: Date, timeout: TimeInterval = 10) -> Bool {
        guard isActive else { return false }
        guard let heartbeatAt else { return true }
        return date.timeIntervalSince(heartbeatAt) > timeout
    }

    func paused(at date: Date) -> RecordingStatus {
        guard phase == .recording else { return self }
        var status = self
        status.phase = .paused
        status.pausedAt = date
        status.heartbeatAt = date
        return status
    }

    func resumed(at date: Date) -> RecordingStatus {
        guard phase == .paused, let pausedAt, let startedAt else { return self }
        var status = self
        status.phase = .recording
        status.startedAt = startedAt.addingTimeInterval(max(0, date.timeIntervalSince(pausedAt)))
        status.pausedAt = nil
        status.heartbeatAt = date
        return status
    }
}
