import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// The recording "notification": Lock Screen banner and Dynamic Island with pause / resume and stop buttons.
struct RecordingLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecordingActivityAttributes.self) { context in
            RecordingLockScreenView(state: context.state, attributes: context.attributes)
                .activityBackgroundTint(WidgetPalette.background)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    RecordingBadge(isPaused: context.state.isPaused)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    RecordingTimer(state: context.state)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .frame(maxWidth: 110, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    RecordingControls(isPaused: context.state.isPaused)
                }
            } compactLeading: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "record.circle.fill")
                    .foregroundStyle(context.state.isPaused ? WidgetPalette.sun : WidgetPalette.record)
            } compactTrailing: {
                RecordingTimer(state: context.state)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .frame(maxWidth: 52)
            } minimal: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "record.circle.fill")
                    .foregroundStyle(context.state.isPaused ? WidgetPalette.sun : WidgetPalette.record)
            }
            .keylineTint(WidgetPalette.record)
        }
    }
}

private struct RecordingLockScreenView: View {
    let state: RecordingActivityAttributes.ContentState
    let attributes: RecordingActivityAttributes

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                RecordingBadge(isPaused: state.isPaused)
                Spacer()
                HStack(spacing: 6) {
                    if attributes.isMicrophoneEnabled { Image(systemName: "mic.fill") }
                    if attributes.isFaceCamEnabled { Image(systemName: "person.crop.circle.fill") }
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
                RecordingTimer(state: state)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .frame(maxWidth: 120, alignment: .trailing)
            }
            RecordingControls(isPaused: state.isPaused)
        }
        .foregroundStyle(.white)
        .padding(16)
    }
}

private struct RecordingBadge: View {
    let isPaused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isPaused ? WidgetPalette.sun : WidgetPalette.record)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 0) {
                Text("RecQuest")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(isPaused ? "Paused" : "Recording")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct RecordingTimer: View {
    let state: RecordingActivityAttributes.ContentState

    var body: some View {
        Text(timerInterval: state.startedAt...Date.distantFuture, pauseTime: state.pausedAt, countsDown: false)
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
            .foregroundStyle(.white)
    }
}

private struct RecordingControls: View {
    let isPaused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if isPaused {
                    Button(intent: ResumeRecordingIntent()) {
                        Label("Resume", systemImage: "play.fill").frame(maxWidth: .infinity)
                    }
                    .tint(WidgetPalette.mint)
                } else {
                    Button(intent: PauseRecordingIntent()) {
                        Label("Pause", systemImage: "pause.fill").frame(maxWidth: .infinity)
                    }
                    .tint(WidgetPalette.sun)
                }
            }
            Button(intent: StopRecordingIntent()) {
                Label("Stop", systemImage: "stop.fill").frame(maxWidth: .infinity)
            }
            .tint(WidgetPalette.record)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .font(.system(.subheadline, design: .rounded, weight: .bold))
        .foregroundStyle(WidgetPalette.ink)
    }
}

/// A few "Arcade Pop" colors; the widget can't see the app's `Palette`.
private enum WidgetPalette {
    static let background = Color(red: 0x1C / 255, green: 0x17 / 255, blue: 0x47 / 255)
    static let record = Color(red: 0xFF / 255, green: 0x4D / 255, blue: 0x6D / 255)
    static let sun = Color(red: 0xFF / 255, green: 0xC9 / 255, blue: 0x3C / 255)
    static let mint = Color(red: 0x2D / 255, green: 0xE1 / 255, blue: 0xC2 / 255)
    static let ink = Color(red: 0x13 / 255, green: 0x10 / 255, blue: 0x4A / 255)
}
