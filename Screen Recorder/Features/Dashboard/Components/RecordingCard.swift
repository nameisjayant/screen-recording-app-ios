import SwiftUI

/// One saved recording: thumbnail, date, length and size, with play / share / save / delete.
struct RecordingCard: View {
    let recording: Recording
    let thumbnail: UIImage?
    let onPlay: () -> Void
    let onSaveToPhotos: () -> Void
    let onDelete: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.l, style: .continuous)

        HStack(spacing: Spacing.m) {
            Button(action: onPlay) {
                HStack(spacing: Spacing.m) {
                    RecordingThumbnail(image: thumbnail)
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(recording.createdAt, format: .dateTime.day().month(.abbreviated).year())
                            .font(.bodyLarge)
                            .foregroundStyle(Palette.textPrimary)
                        Text(recording.createdAt, format: .dateTime.hour().minute())
                            .font(.bodyMedium)
                            .foregroundStyle(Palette.textSecondary)
                        HStack(spacing: Spacing.xs) {
                            InfoChip(icon: "clock.fill", text: RecordingFormat.duration(recording.duration), tint: Palette.sun)
                            InfoChip(icon: "internaldrive.fill", text: RecordingFormat.size(recording.fileSize), tint: Palette.mint)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("Plays the recording"))

            Menu {
                Button("Play", systemImage: "play.fill", action: onPlay)
                ShareLink(item: recording.url) { Label("Share", systemImage: "square.and.arrow.up") }
                Button("Save to Photos", systemImage: "photo.on.rectangle.angled", action: onSaveToPhotos)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Palette.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.surfaceRaised))
            }
            .accessibilityLabel(Text("More actions"))
            .accessibilityIdentifier("dashboard.recording.menu")
        }
        .padding(Spacing.s)
        .background {
            shape.fill(Palette.surface)
                .overlay(shape.stroke(Palette.outline, lineWidth: 2))
        }
        .background { shape.fill(Palette.backgroundDeep).offset(y: Motion.pressDepth) }
        .padding(.bottom, Motion.pressDepth)
        .contextMenu {
            ShareLink(item: recording.url) { Label("Share", systemImage: "square.and.arrow.up") }
            Button("Save to Photos", systemImage: "photo.on.rectangle.angled", action: onSaveToPhotos)
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
        .accessibilityIdentifier("dashboard.recording")
    }
}

private struct RecordingThumbnail: View {
    let image: UIImage?

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.s, style: .continuous)

        ZStack {
            shape.fill(Palette.surfaceRaised)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "film")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Palette.textMuted)
            }
            Image(systemName: "play.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Palette.record))
        }
        .frame(width: 64, height: 108)
        .clipShape(shape)
        .overlay(shape.stroke(Palette.outline, lineWidth: 1.5))
        .accessibilityHidden(true)
    }
}

private struct InfoChip: View {
    let icon: String
    let text: String
    let tint: Color

    var body: some View {
        Label {
            Text(verbatim: text)
        } icon: {
            Image(systemName: icon).foregroundStyle(tint)
        }
        .font(.label)
        .foregroundStyle(Palette.textSecondary)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(Capsule().fill(tint.opacity(0.14)))
    }
}

enum RecordingFormat {
    static func duration(_ seconds: TimeInterval) -> String {
        Duration.seconds(seconds.rounded()).formatted(.time(pattern: seconds >= 3600 ? .hourMinuteSecond : .minuteSecond))
    }

    static func size(_ bytes: Int64) -> String {
        bytes.formatted(.byteCount(style: .file))
    }
}

#Preview {
    RecordingCard(recording: Recording(url: URL(filePath: "/tmp/RecQuest.mp4"), createdAt: .now, duration: 95, fileSize: 48_000_000),
                  thumbnail: nil, onPlay: {}, onSaveToPhotos: {}, onDelete: {})
        .padding()
        .background(AppBackground())
}
