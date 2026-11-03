import Foundation
import ReplayKit

/// Broadcast Upload Extension entry point. iOS runs it in its own process for the whole recording,
/// so it keeps going when the app is in the background or closed.
///
/// All mutable state is touched only on `queue`.
final class SampleHandler: RPBroadcastSampleHandler, @unchecked Sendable {
    private let channel = RecordingChannel()
    private let queue = DispatchQueue(label: "RecQuestBroadcast.recording")

    private var writer: RecordingWriter?
    private var status = RecordingStatus.idle
    private var observations: [DarwinObservation] = []
    private var heartbeat: DispatchSourceTimer?
    private var isFinishing = false

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        queue.sync {
            let directory = channel.recordingsDirectory ?? FileManager.default.temporaryDirectory
            writer = try? RecordingWriter(directory: directory, includesMicrophone: channel.isMicrophoneEnabled)
            if writer == nil {
                // Nothing to record into: end right away instead of recording silently into nowhere.
                queue.async { self.finish(message: String(localized: "RecQuest couldn't create the recording file.")) }
                return
            }
            publish(.started(at: .now))
            observeCommands()
            startHeartbeat()
        }
    }

    override func broadcastPaused() {
        queue.sync { pause() }
    }

    override func broadcastResumed() {
        queue.sync { resume() }
    }

    override func broadcastFinished() {
        // Stopped from the system (status bar, Control Center): iOS ends the process once this returns,
        // so wait for the file to be written.
        let done = DispatchSemaphore(value: 0)
        queue.async {
            self.tearDown { done.signal() }
        }
        _ = done.wait(timeout: .now() + 10)
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        queue.sync {
            guard status.phase == .recording, let writer else { return }
            switch sampleBufferType {
            case .video: writer.appendVideo(sampleBuffer)
            case .audioApp: writer.appendAppAudio(sampleBuffer)
            case .audioMic: writer.appendMicrophoneAudio(sampleBuffer)
            @unknown default: break
            }
        }
    }

    // MARK: - Commands (on `queue`)

    private func observeCommands() {
        observations = [
            channel.observe(.pause) { [weak self] in self?.onQueue { $0.pause() } },
            channel.observe(.resume) { [weak self] in self?.onQueue { $0.resume() } },
            channel.observe(.stop) { [weak self] in
                self?.onQueue { $0.finish(message: String(localized: "Your recording was saved in RecQuest.")) }
            },
        ]
    }

    private func pause() {
        guard status.phase == .recording else { return }
        writer?.pause()
        publish(status.paused(at: .now))
    }

    private func resume() {
        guard status.phase == .paused else { return }
        publish(status.resumed(at: .now))
    }

    /// Stop requested from RecQuest: save the file, then end the broadcast. ReplayKit only lets an extension
    /// end itself through `finishBroadcastWithError`, so iOS shows `message` in its "stopped" alert.
    private func finish(message: String) {
        tearDown { [weak self] in
            let error = NSError(domain: "RecQuestBroadcast", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
            self?.finishBroadcastWithError(error)
        }
    }

    private func tearDown(completion: @escaping @Sendable () -> Void) {
        guard !isFinishing else { return completion() }
        isFinishing = true
        heartbeat?.cancel()
        heartbeat = nil
        observations = []
        guard let writer else {
            publish(.idle)
            return completion()
        }
        self.writer = nil
        writer.finish { [weak self] in
            guard let self else { return completion() }
            onQueue {
                $0.publish(.idle)
                completion()
            }
        }
    }

    private func startHeartbeat() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 2, repeating: 2)
        timer.setEventHandler { [weak self] in
            guard let self, status.isActive else { return }
            status.heartbeatAt = .now
            channel.status = status
        }
        timer.resume()
        heartbeat = timer
    }

    private func onQueue(_ work: @escaping @Sendable (SampleHandler) -> Void) {
        queue.async { work(self) }
    }

    private func publish(_ newStatus: RecordingStatus) {
        status = newStatus
        channel.status = newStatus
        channel.post(.statusChanged)
    }
}
