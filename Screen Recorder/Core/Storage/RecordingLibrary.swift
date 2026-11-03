import AVFoundation
import Photos
import UIKit

/// Finished recordings stored on the device.
nonisolated protocol RecordingLibrary: Sendable {
    /// Newest first. Also moves in any recordings the broadcast extension has finished since the last call.
    func recordings() async -> [Recording]
    func thumbnail(for recording: Recording) async -> UIImage?
    func delete(_ recording: Recording) async throws
    func saveToPhotos(_ recording: Recording) async throws
}

nonisolated enum RecordingLibraryError: Error {
    case photosAccessDenied
}

/// Keeps recordings in `Documents/Recordings`, which the Files app shows under On My iPhone › RecQuest.
///
/// The broadcast extension can only write to the shared App Group container, so finished files are moved
/// from there into Documents the next time the list is loaded.
actor FileRecordingLibrary: RecordingLibrary {
    private let channel: RecordingChannel
    private let directory: URL
    private let fileManager = FileManager.default

    init(channel: RecordingChannel = RecordingChannel(),
         directory: URL = URL.documentsDirectory.appending(path: "Recordings", directoryHint: .isDirectory)) {
        self.channel = channel
        self.directory = directory
    }

    func recordings() async -> [Recording] {
        importFinishedRecordings()
        let keys: [URLResourceKey] = [.creationDateKey, .fileSizeKey]
        let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: keys)) ?? []

        var recordings: [Recording] = []
        for url in files where url.pathExtension.lowercased() == "mp4" {
            let values = try? url.resourceValues(forKeys: Set(keys))
            let duration = (try? await AVURLAsset(url: url).load(.duration).seconds) ?? 0
            recordings.append(Recording(url: url,
                                        createdAt: values?.creationDate ?? .distantPast,
                                        duration: duration.isFinite ? duration : 0,
                                        fileSize: Int64(values?.fileSize ?? 0)))
        }
        return recordings.sorted { $0.createdAt > $1.createdAt }
    }

    func thumbnail(for recording: Recording) async -> UIImage? {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: recording.url))
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 240, height: 240)
        let time = CMTime(seconds: min(1, recording.duration / 2), preferredTimescale: 600)
        guard let image = try? await generator.image(at: time).image else { return nil }
        return UIImage(cgImage: image)
    }

    func delete(_ recording: Recording) async throws {
        try fileManager.removeItem(at: recording.url)
    }

    func saveToPhotos(_ recording: Recording) async throws {
        guard await PHPhotoLibrary.requestAuthorization(for: .addOnly) == .authorized else {
            throw RecordingLibraryError.photosAccessDenied
        }
        let url = recording.url
        try await PHPhotoLibrary.shared().performChanges {
            _ = PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }

    // MARK: - Private

    private func importFinishedRecordings() {
        guard let source = channel.recordingsDirectory,
              var files = try? fileManager.contentsOfDirectory(at: source, includingPropertiesForKeys: [.creationDateKey])
        else { return }
        files = files.filter { $0.pathExtension.lowercased() == "mp4" }
        if channel.status.isActive {
            // The newest file is the one being recorded right now.
            let newest = files.max { creationDate(of: $0) < creationDate(of: $1) }
            files.removeAll { $0 == newest }
        }
        guard !files.isEmpty else { return }

        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        for file in files {
            try? fileManager.moveItem(at: file, to: availableURL(for: file.lastPathComponent))
        }
    }

    private func creationDate(of url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
    }

    private func availableURL(for fileName: String) -> URL {
        var url = directory.appending(path: fileName)
        let base = url.deletingPathExtension().lastPathComponent
        var index = 2
        while fileManager.fileExists(atPath: url.path()) {
            url = directory.appending(path: "\(base) \(index).mp4")
            index += 1
        }
        return url
    }
}
