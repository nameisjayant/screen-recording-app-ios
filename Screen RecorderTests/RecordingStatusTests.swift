import Foundation
import Testing
@testable import Screen_Recorder

struct RecordingStatusTests {
    private let start = Date(timeIntervalSince1970: 1_000)

    @Test func elapsedCountsOnlyRecordedTime() {
        var status = RecordingStatus.started(at: start)
        #expect(status.elapsed(at: start.addingTimeInterval(10)) == 10)

        status = status.paused(at: start.addingTimeInterval(10))
        #expect(status.phase == .paused)
        #expect(status.elapsed(at: start.addingTimeInterval(60)) == 10, "The clock stops while paused")

        status = status.resumed(at: start.addingTimeInterval(40))
        #expect(status.phase == .recording)
        #expect(status.pausedAt == nil)
        #expect(status.startedAt == start.addingTimeInterval(30), "Start moves forward by the 30s pause")
        #expect(status.elapsed(at: start.addingTimeInterval(45)) == 15)
    }

    @Test func pauseAndResumeOnlyApplyInTheRightPhase() {
        let recording = RecordingStatus.started(at: start)
        #expect(recording.resumed(at: start) == recording)
        #expect(RecordingStatus.idle.paused(at: start) == .idle)

        let paused = recording.paused(at: start.addingTimeInterval(5))
        #expect(paused.paused(at: start.addingTimeInterval(9)) == paused)
    }

    @Test func staleOnlyWhenActiveWithoutRecentHeartbeat() {
        let status = RecordingStatus.started(at: start)
        #expect(!status.isStale(at: start.addingTimeInterval(5)))
        #expect(status.isStale(at: start.addingTimeInterval(11)))
        #expect(!RecordingStatus.idle.isStale(at: start.addingTimeInterval(100)))
    }

    @Test func liveActivityStateFollowsStatus() {
        #expect(RecordingActivityAttributes.ContentState(status: .idle) == nil)

        let paused = RecordingStatus.started(at: start).paused(at: start.addingTimeInterval(3))
        let state = RecordingActivityAttributes.ContentState(status: paused)
        #expect(state?.startedAt == start)
        #expect(state?.isPaused == true)
    }
}
