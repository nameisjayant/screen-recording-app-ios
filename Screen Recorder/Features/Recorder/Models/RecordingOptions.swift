/// What to capture alongside the screen when a recording starts.
nonisolated struct RecordingOptions: Equatable, Sendable {
    var isFaceCamEnabled = false
    var isMicrophoneEnabled = true
}
