import Foundation
import Testing
import UIKit
@testable import Screen_Recorder

private actor FakeLibrary: RecordingLibrary {
    var stored: [Recording]
    var saveError: Error?
    private(set) var deleted: [Recording] = []
    private(set) var savedToPhotos: [Recording] = []

    init(_ stored: [Recording] = [], saveError: Error? = nil) {
        self.stored = stored
        self.saveError = saveError
    }

    func add(_ recording: Recording) { stored.insert(recording, at: 0) }

    func recordings() async -> [Recording] { stored }
    func thumbnail(for recording: Recording) async -> UIImage? { nil }

    func delete(_ recording: Recording) async throws {
        deleted.append(recording)
        stored.removeAll { $0.id == recording.id }
    }

    func saveToPhotos(_ recording: Recording) async throws {
        if let saveError { throw saveError }
        savedToPhotos.append(recording)
    }
}

@MainActor
struct DashboardViewModelTests {
    private func recording(_ name: String, duration: TimeInterval = 60, size: Int64 = 1_000) -> Recording {
        Recording(url: URL(filePath: "/tmp/\(name).mp4"), createdAt: .now, duration: duration, fileSize: size)
    }

    @Test func refreshLoadsRecordingsAndTotals() async {
        let library = FakeLibrary([recording("b", duration: 30, size: 500), recording("a", duration: 90, size: 1_500)])
        let viewModel = DashboardViewModel(library: library, recorder: FakeRecorder())
        #expect(viewModel.state.isLoading)

        await viewModel.perform(.refresh)

        #expect(!viewModel.state.isLoading)
        #expect(viewModel.state.recordings.map(\.id) == ["b.mp4", "a.mp4"])
        #expect(viewModel.state.totalDuration == 120)
        #expect(viewModel.state.totalSize == 2_000)
    }

    @Test func deleteNeedsConfirmation() async {
        let target = recording("a")
        let library = FakeLibrary([target, recording("b")])
        let viewModel = DashboardViewModel(library: library, recorder: FakeRecorder())
        await viewModel.perform(.refresh)

        await viewModel.perform(.requestDelete(target))
        #expect(viewModel.state.pendingDeletion == target)
        await viewModel.perform(.cancelDelete)
        #expect(viewModel.state.pendingDeletion == nil)
        #expect(await library.deleted.isEmpty)

        await viewModel.perform(.requestDelete(target))
        await viewModel.perform(.confirmDelete)
        #expect(await library.deleted == [target])
        #expect(viewModel.state.recordings.map(\.id) == ["b.mp4"])
    }

    @Test func saveToPhotosShowsResult() async {
        let target = recording("a")
        let viewModel = DashboardViewModel(library: FakeLibrary([target]), recorder: FakeRecorder())
        await viewModel.perform(.saveToPhotos(target))
        #expect(viewModel.state.banner == .savedToPhotos)

        await viewModel.perform(.dismissBanner)
        #expect(viewModel.state.banner == nil)

        let denied = DashboardViewModel(library: FakeLibrary([target], saveError: RecordingLibraryError.photosAccessDenied),
                                        recorder: FakeRecorder())
        await denied.perform(.saveToPhotos(target))
        #expect(denied.state.banner == .photosAccessDenied)
    }

    @Test func playOpensAndClosesPlayer() async {
        let target = recording("a")
        let viewModel = DashboardViewModel(library: FakeLibrary([target]), recorder: FakeRecorder())

        await viewModel.perform(.play(target))
        #expect(viewModel.state.playing == target)
        await viewModel.perform(.dismissPlayer)
        #expect(viewModel.state.playing == nil)
    }

    @Test func reloadsWhenARecordingFinishes() async throws {
        let library = FakeLibrary()
        let recorder = FakeRecorder()
        let viewModel = DashboardViewModel(library: library, recorder: recorder)
        await viewModel.perform(.refresh)
        #expect(viewModel.state.recordings.isEmpty)

        recorder.state = RecorderState(status: .started(at: .now))
        await library.add(recording("new"))
        recorder.state = RecorderState()

        for _ in 0..<50 where viewModel.state.recordings.isEmpty {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(viewModel.state.recordings.map(\.id) == ["new.mp4"])
    }
}
