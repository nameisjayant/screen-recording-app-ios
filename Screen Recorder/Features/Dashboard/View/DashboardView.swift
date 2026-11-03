import AVKit
import SwiftUI

/// Dashboard tab: every recording saved on the device, newest first.
struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: DashboardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let state = viewModel.state

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("Dashboard")
                    .font(.displayLarge)
                    .foregroundStyle(Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("home.title")

                if !state.recordings.isEmpty {
                    DashboardSummary(count: state.recordings.count,
                                     totalDuration: state.totalDuration,
                                     totalSize: state.totalSize)
                }

                LazyVStack(spacing: Spacing.m) {
                    ForEach(state.recordings) { recording in
                        RecordingCard(recording: recording,
                                      thumbnail: state.thumbnails[recording.id],
                                      onPlay: { viewModel.send(.play(recording)) },
                                      onSaveToPhotos: { viewModel.send(.saveToPhotos(recording)) },
                                      onDelete: { viewModel.send(.requestDelete(recording)) })
                            .task { viewModel.send(.loadThumbnail(recording)) }
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                }
            }
            .padding(Spacing.l)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: state.recordings)
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.perform(.refresh) }
        .overlay {
            if state.recordings.isEmpty, !state.isLoading {
                PlaceholderScreen(icon: "film.stack",
                                  title: "No recordings yet",
                                  message: "Tap the microphone button to record your screen. Your recordings will show up here.",
                                  tint: HomeTab.dashboard.accent)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .top) { banner }
        .task { viewModel.send(.refresh) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.send(.refresh) }
        }
        .fullScreenCover(item: Binding(get: { viewModel.state.playing },
                                       set: { if $0 == nil { viewModel.send(.dismissPlayer) } })) { recording in
            RecordingPlayerView(recording: recording) { viewModel.send(.dismissPlayer) }
        }
        .confirmationDialog("Delete this recording?",
                            isPresented: Binding(get: { viewModel.state.pendingDeletion != nil },
                                                 set: { if !$0 { viewModel.send(.cancelDelete) } }),
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { viewModel.send(.confirmDelete) }
            Button("Cancel", role: .cancel) { viewModel.send(.cancelDelete) }
        } message: {
            Text("It will be removed from this device. Copies saved to Photos stay there.")
        }
    }

    @ViewBuilder
    private var banner: some View {
        if let banner = viewModel.state.banner {
            DashboardBannerView(banner: banner)
                .padding(.top, Spacing.xs)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task(id: banner) {
                    try? await Task.sleep(for: .seconds(2.5))
                    viewModel.send(.dismissBanner)
                }
        }
    }
}

private struct DashboardSummary: View {
    let count: Int
    let totalDuration: TimeInterval
    let totalSize: Int64

    var body: some View {
        HStack(spacing: Spacing.s) {
            SummaryTile(icon: "film.stack.fill", value: Text("\(count)"), label: "Recordings", tint: Palette.primary)
            SummaryTile(icon: "clock.fill", value: Text(RecordingFormat.duration(totalDuration)), label: "Total time", tint: Palette.sun)
            SummaryTile(icon: "internaldrive.fill", value: Text(RecordingFormat.size(totalSize)), label: "Storage", tint: Palette.mint)
        }
    }
}

private struct SummaryTile: View {
    let icon: String
    let value: Text
    let label: LocalizedStringResource
    let tint: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.m, style: .continuous)

        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
            value
                .font(.displaySmall)
                .foregroundStyle(Palette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.label)
                .foregroundStyle(Palette.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s)
        .background {
            shape.fill(Palette.surface)
                .overlay(shape.stroke(Palette.outline, lineWidth: 2))
        }
        .accessibilityElement(children: .combine)
    }
}

private struct DashboardBannerView: View {
    let banner: DashboardBanner

    var body: some View {
        let (icon, text, tint): (String, LocalizedStringResource, Color) = switch banner {
        case .savedToPhotos: ("checkmark.circle.fill", "Saved to Photos", Palette.mint)
        case .photosAccessDenied: ("photo.badge.exclamationmark", "Allow Photos access in Settings to save", Palette.sun)
        case .failed: ("exclamationmark.triangle.fill", "Something went wrong. Try again.", Palette.record)
        }

        Label { Text(text) } icon: { Image(systemName: icon).foregroundStyle(tint) }
            .font(.bodyLarge)
            .foregroundStyle(Palette.textPrimary)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Capsule().fill(Palette.surfaceRaised))
            .overlay(Capsule().stroke(tint.opacity(0.6), lineWidth: 2))
            .accessibilityIdentifier("dashboard.banner")
    }
}

/// Full-screen playback of a recording.
private struct RecordingPlayerView: View {
    let recording: Recording
    let onClose: () -> Void

    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .background(Color.black)
            .overlay(alignment: .topLeading) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.black.opacity(0.5)))
                }
                .accessibilityLabel(Text("Close"))
                .padding(Spacing.m)
            }
            .onAppear {
                let player = AVPlayer(url: recording.url)
                self.player = player
                player.play()
            }
            .onDisappear { player?.pause() }
    }
}
