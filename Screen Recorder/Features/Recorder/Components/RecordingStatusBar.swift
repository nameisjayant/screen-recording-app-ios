import SwiftUI

/// Pill above the bottom bar while a recording runs: status, timer, pause / resume and stop.
struct RecordingStatusBar: View {
    let status: RecordingStatus
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void

    @State private var isPulsing = false

    private var isPaused: Bool { status.phase == .paused }

    var body: some View {
        let shape = Capsule()

        HStack(spacing: Spacing.s) {
            Circle()
                .fill(isPaused ? Palette.sun : Palette.record)
                .frame(width: 12, height: 12)
                .opacity(isPaused || !isPulsing ? 1 : 0.35)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                .onAppear { isPulsing = true }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(isPaused ? "Paused" : "Recording")
                    .font(.label)
                    .foregroundStyle(Palette.textSecondary)
                timer
                    .font(.displaySmall)
                    .foregroundStyle(Palette.textPrimary)
            }

            Spacer(minLength: 0)

            if isPaused {
                RecordingControlButton(icon: "play.fill", label: "Resume", tint: Palette.mint, action: onResume)
                    .accessibilityIdentifier("recording.resume")
            } else {
                RecordingControlButton(icon: "pause.fill", label: "Pause", tint: Palette.sun, action: onPause)
                    .accessibilityIdentifier("recording.pause")
            }
            RecordingControlButton(icon: "stop.fill", label: "Stop", tint: Palette.record, action: onStop)
                .accessibilityIdentifier("recording.stop")
        }
        .padding(.leading, Spacing.m)
        .padding(.trailing, Spacing.xs)
        .padding(.vertical, Spacing.xs)
        .background {
            shape.fill(Palette.surface)
                .overlay(shape.stroke(Palette.outline, lineWidth: 2))
        }
        .padding(.horizontal, Spacing.m)
        .sensoryFeedback(.impact, trigger: status.phase)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("recording.statusBar")
    }

    @ViewBuilder
    private var timer: some View {
        if let startedAt = status.startedAt {
            Text(timerInterval: startedAt...Date.distantFuture, pauseTime: status.pausedAt, countsDown: false)
                .monospacedDigit()
        } else {
            Text(verbatim: "0:00")
        }
    }
}

private struct RecordingControlButton: View {
    let icon: String
    let label: LocalizedStringResource
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(tint == Palette.record ? .white : Palette.ink)
                .frame(width: 44, height: 44)
                .background(Circle().fill(tint))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        RecordingStatusBar(status: .started(at: .now.addingTimeInterval(-75)), onPause: {}, onResume: {}, onStop: {})
        RecordingStatusBar(status: RecordingStatus.started(at: .now.addingTimeInterval(-30)).paused(at: .now),
                           onPause: {}, onResume: {}, onStop: {})
    }
    .frame(maxHeight: .infinity)
    .background(AppBackground())
}
