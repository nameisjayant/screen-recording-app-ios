@testable import Screen_Recorder

@MainActor
final class FakeRecorder: RecordingService {
    var state = RecorderState() {
        didSet { observers = observers.filter { $0(state) } }
    }
    private var observers: [(RecorderState) -> Bool] = []
    private(set) var started: [RecordingOptions] = []
    private(set) var commands: [String] = []

    func observeState(_ observer: @escaping (RecorderState) -> Bool) { observers.append(observer) }
    func start(with options: RecordingOptions) { started.append(options) }
    func pause() { commands.append("pause") }
    func resume() { commands.append("resume") }
    func stop() { commands.append("stop") }
}
