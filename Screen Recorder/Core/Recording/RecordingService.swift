/// What the Home screen sees of the recorder.
nonisolated struct RecorderState: Equatable, Sendable {
    var status = RecordingStatus.idle
    /// The face cam bubble is live (recording with face cam enabled).
    var isFaceCamOn = false
}

/// Starts and controls screen recordings. The live implementation is `ScreenRecordingController`.
protocol RecordingService: AnyObject {
    var state: RecorderState { get }
    /// Calls `observer` on every `state` change for as long as it returns true.
    func observeState(_ observer: @escaping (RecorderState) -> Bool)

    /// Shows the iOS broadcast sheet; the recording begins once the user confirms there.
    func start(with options: RecordingOptions)
    func pause()
    func resume()
    func stop()
}
