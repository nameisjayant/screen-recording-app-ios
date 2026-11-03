import AVFoundation
import ReplayKit

/// Writes ReplayKit's screen, app audio and microphone buffers to an MP4, skipping the time spent paused.
///
/// Not thread-safe: `SampleHandler` calls it from one serial queue.
final class RecordingWriter {
    private let writer: AVAssetWriter
    private let includesMicrophone: Bool

    private var videoInput: AVAssetWriterInput?
    private var appAudioInput: AVAssetWriterInput?
    private var microphoneInput: AVAssetWriterInput?

    private var hasStartedSession = false
    /// Total paused time, subtracted from every timestamp so the file has no gaps.
    private var pauseOffset = CMTime.zero
    private var needsOffsetUpdate = false
    private var lastTimestamp = CMTime.invalid
    private var lastTimestamps: [ObjectIdentifier: CMTime] = [:]

    init(directory: URL, includesMicrophone: Bool) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        let url = directory.appending(path: "RecQuest \(formatter.string(from: .now)).mp4")

        writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        writer.shouldOptimizeForNetworkUse = true
        self.includesMicrophone = includesMicrophone
    }

    // MARK: - Appending

    func appendVideo(_ buffer: CMSampleBuffer) {
        if videoInput == nil {
            // Inputs are created from the first frame, which tells us the screen size.
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer), !startWriting(with: pixelBuffer) else { return }
        }
        if !hasStartedSession {
            guard writer.status == .writing else { return }
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
            hasStartedSession = true
        }
        append(buffer, to: videoInput)
    }

    func appendAppAudio(_ buffer: CMSampleBuffer) {
        append(buffer, to: appAudioInput)
    }

    func appendMicrophoneAudio(_ buffer: CMSampleBuffer) {
        append(buffer, to: microphoneInput)
    }

    // MARK: - Pause

    /// Call when pausing. No buffers should be appended until resumed; the paused gap is measured
    /// on the first buffer that arrives afterwards (see `retimed`).
    func pause() {
        needsOffsetUpdate = true
    }

    func finish(completion: @escaping @Sendable () -> Void) {
        guard writer.status == .writing, hasStartedSession else {
            writer.cancelWriting()
            try? FileManager.default.removeItem(at: writer.outputURL)
            return completion()
        }
        [videoInput, appAudioInput, microphoneInput].forEach { $0?.markAsFinished() }
        writer.finishWriting(completionHandler: completion)
    }

    // MARK: - Private

    /// Returns true when setup failed and the frame should be dropped.
    private func startWriting(with pixelBuffer: CVPixelBuffer) -> Bool {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let video = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: max(width * height * 4, 4_000_000),
                AVVideoExpectedSourceFrameRateKey: 60,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            ],
        ])
        video.expectsMediaDataInRealTime = true

        let appAudio = Self.makeAudioInput(channels: 2)
        let microphone = includesMicrophone ? Self.makeAudioInput(channels: 1) : nil

        for input in [video, appAudio, microphone].compactMap({ $0 }) where writer.canAdd(input) {
            writer.add(input)
        }
        videoInput = video
        appAudioInput = writer.inputs.contains(appAudio) ? appAudio : nil
        microphoneInput = microphone.flatMap { writer.inputs.contains($0) ? $0 : nil }

        return !writer.startWriting()
    }

    private static func makeAudioInput(channels: Int) -> AVAssetWriterInput {
        let input = AVAssetWriterInput(mediaType: .audio, outputSettings: [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: channels,
            AVEncoderBitRateKey: channels == 1 ? 96_000 : 128_000,
        ])
        input.expectsMediaDataInRealTime = true
        return input
    }

    private func append(_ buffer: CMSampleBuffer, to input: AVAssetWriterInput?) {
        guard hasStartedSession, writer.status == .writing, let input, input.isReadyForMoreMediaData,
              let retimed = retimed(buffer) else { return }

        let timestamp = CMSampleBufferGetPresentationTimeStamp(retimed)
        let key = ObjectIdentifier(input)
        // Each track must only move forward.
        if let last = lastTimestamps[key], timestamp <= last { return }
        if input.append(retimed) {
            lastTimestamps[key] = timestamp
            if !lastTimestamp.isValid || timestamp > lastTimestamp { lastTimestamp = timestamp }
        }
    }

    /// Shifts `buffer` back by the total paused time.
    private func retimed(_ buffer: CMSampleBuffer) -> CMSampleBuffer? {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(buffer)
        if needsOffsetUpdate {
            needsOffsetUpdate = false
            if lastTimestamp.isValid {
                let gap = timestamp - pauseOffset - lastTimestamp
                if gap > .zero { pauseOffset = pauseOffset + gap }
            }
        }
        guard pauseOffset > .zero else { return buffer }

        var count: CMItemCount = 0
        CMSampleBufferGetSampleTimingInfoArray(buffer, entryCount: 0, arrayToFill: nil, entriesNeededOut: &count)
        var timings = [CMSampleTimingInfo](repeating: CMSampleTimingInfo(), count: count)
        CMSampleBufferGetSampleTimingInfoArray(buffer, entryCount: count, arrayToFill: &timings, entriesNeededOut: &count)
        for index in timings.indices {
            timings[index].presentationTimeStamp = timings[index].presentationTimeStamp - pauseOffset
            if timings[index].decodeTimeStamp.isValid {
                timings[index].decodeTimeStamp = timings[index].decodeTimeStamp - pauseOffset
            }
        }

        var copy: CMSampleBuffer?
        CMSampleBufferCreateCopyWithNewTiming(allocator: kCFAllocatorDefault, sampleBuffer: buffer,
                                              sampleTimingEntryCount: count, sampleTimingArray: &timings,
                                              sampleBufferOut: &copy)
        return copy
    }
}
