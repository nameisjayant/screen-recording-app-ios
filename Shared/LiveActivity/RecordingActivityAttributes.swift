import ActivityKit
import Foundation

/// Live Activity shown on the Lock Screen and in the Dynamic Island while a recording runs.
nonisolated struct RecordingActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable, Sendable {
        /// Same meaning as `RecordingStatus.startedAt`: shifted by pauses so a running timer shows the recorded length.
        var startedAt: Date
        var pausedAt: Date?

        var isPaused: Bool { pausedAt != nil }

        init(startedAt: Date, pausedAt: Date?) {
            self.startedAt = startedAt
            self.pausedAt = pausedAt
        }

        init?(status: RecordingStatus) {
            guard status.isActive, let startedAt = status.startedAt else { return nil }
            self.init(startedAt: startedAt, pausedAt: status.phase == .paused ? status.pausedAt ?? .now : nil)
        }
    }

    var isMicrophoneEnabled: Bool
    var isFaceCamEnabled: Bool
}

/// Starts, updates and ends the recording Live Activity so it mirrors `RecordingStatus`.
nonisolated enum RecordingLiveActivity {
    static func sync(with status: RecordingStatus,
                     attributes: @autoclosure () -> RecordingActivityAttributes? = nil) async {
        let activities = Activity<RecordingActivityAttributes>.activities
        guard let state = RecordingActivityAttributes.ContentState(status: status) else {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            return
        }

        let content = ActivityContent(state: state, staleDate: nil)
        if activities.isEmpty {
            // Starting needs the app in the foreground; callers pass attributes only from there.
            guard let attributes = attributes(),
                  ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            _ = try? Activity.request(attributes: attributes, content: content, pushType: nil)
        } else {
            for activity in activities {
                await activity.update(content)
            }
        }
    }
}
