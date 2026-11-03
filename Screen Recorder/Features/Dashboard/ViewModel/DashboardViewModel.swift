import Observation
import UIKit

nonisolated enum DashboardBanner: Equatable, Sendable {
    case savedToPhotos
    case photosAccessDenied
    case failed
}

nonisolated struct DashboardState: Equatable, Sendable {
    var recordings: [Recording] = []
    var thumbnails: [Recording.ID: UIImage] = [:]
    var isLoading = true
    var playing: Recording?
    var pendingDeletion: Recording?
    var banner: DashboardBanner?

    var totalDuration: TimeInterval { recordings.reduce(0) { $0 + $1.duration } }
    var totalSize: Int64 { recordings.reduce(0) { $0 + $1.fileSize } }
}

enum DashboardIntent {
    case refresh
    case loadThumbnail(Recording)
    case play(Recording)
    case dismissPlayer
    case requestDelete(Recording)
    case cancelDelete
    case confirmDelete
    case saveToPhotos(Recording)
    case dismissBanner
}

@Observable
final class DashboardViewModel: ViewModel {
    private(set) var state = DashboardState()

    @ObservationIgnored private let library: RecordingLibrary
    @ObservationIgnored private var wasRecording: Bool

    init(library: RecordingLibrary, recorder: RecordingService) {
        self.library = library
        self.wasRecording = recorder.state.status.isActive
        recorder.observeState { [weak self] recorderState in
            guard let self else { return false }
            // A recording just finished: pick up the new file.
            let isRecording = recorderState.status.isActive
            if wasRecording, !isRecording { send(.refresh) }
            wasRecording = isRecording
            return true
        }
    }

    func send(_ intent: DashboardIntent) {
        Task { await perform(intent) }
    }

    /// `send` without the fire-and-forget, so tests can wait for the result.
    func perform(_ intent: DashboardIntent) async {
        switch intent {
        case .refresh:
            let recordings = await library.recordings()
            state.recordings = recordings
            state.thumbnails = state.thumbnails.filter { id, _ in recordings.contains { $0.id == id } }
            state.isLoading = false
        case .loadThumbnail(let recording):
            guard state.thumbnails[recording.id] == nil,
                  let image = await library.thumbnail(for: recording) else { return }
            state.thumbnails[recording.id] = image
        case .play(let recording):
            state.playing = recording
        case .dismissPlayer:
            state.playing = nil
        case .requestDelete(let recording):
            state.pendingDeletion = recording
        case .cancelDelete:
            state.pendingDeletion = nil
        case .confirmDelete:
            guard let recording = state.pendingDeletion else { return }
            state.pendingDeletion = nil
            do {
                try await library.delete(recording)
                state.recordings.removeAll { $0.id == recording.id }
                state.thumbnails[recording.id] = nil
            } catch {
                state.banner = .failed
            }
        case .saveToPhotos(let recording):
            do {
                try await library.saveToPhotos(recording)
                state.banner = .savedToPhotos
            } catch RecordingLibraryError.photosAccessDenied {
                state.banner = .photosAccessDenied
            } catch {
                state.banner = .failed
            }
        case .dismissBanner:
            state.banner = nil
        }
    }
}
