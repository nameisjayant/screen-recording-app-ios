import SwiftUI

/// Pop-up card shown from the bottom bar's microphone button: pick face cam / microphone, then start recording.
struct RecordingSetupDialog: View {
    let options: RecordingOptions
    let onFaceCamChange: (Bool) -> Void
    let onMicrophoneChange: (Bool) -> Void
    let onStart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.l, style: .continuous)

        VStack(spacing: Spacing.l) {
            header

            VStack(spacing: Spacing.s) {
                RecordingOptionRow(icon: "person.crop.circle.fill",
                                   title: "Face Camera",
                                   subtitle: "Show your face in a bubble",
                                   tint: Palette.sun,
                                   isOn: options.isFaceCamEnabled,
                                   onChange: onFaceCamChange)
                    .accessibilityIdentifier("recordingSetup.faceCam")
                RecordingOptionRow(icon: "mic.fill",
                                   title: "Microphone",
                                   subtitle: "Record your voice commentary",
                                   tint: Palette.mint,
                                   isOn: options.isMicrophoneEnabled,
                                   onChange: onMicrophoneChange)
                    .accessibilityIdentifier("recordingSetup.microphone")
            }

            VStack(spacing: Spacing.xs) {
                Button(action: onStart) {
                    Label("Start Recording", systemImage: "record.circle.fill")
                }
                .buttonStyle(.game(.record))
                .accessibilityIdentifier("recordingSetup.start")

                Button("Cancel", action: onDismiss)
                    .font(.buttonLabel)
                    .foregroundStyle(Palette.textSecondary)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("recordingSetup.cancel")
            }
        }
        .padding(Spacing.l)
        .background {
            shape.fill(Palette.surface)
                .overlay(shape.stroke(Palette.outline, lineWidth: 2))
        }
        .background { shape.fill(Palette.backgroundDeep).offset(y: Motion.pressDepth) }
        .padding(.horizontal, Spacing.l)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityIdentifier("recordingSetup.dialog")
    }

    private var header: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "record.circle.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Palette.record)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Palette.record.opacity(0.16)))
                .overlay(Circle().stroke(Palette.record.opacity(0.5), lineWidth: 2))
                .accessibilityHidden(true)
            Text("New Recording")
                .font(.displayMedium)
                .foregroundStyle(Palette.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Choose what to capture along with your screen.")
                .font(.bodyMedium)
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct RecordingOptionRow: View {
    let icon: String
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let tint: Color
    let isOn: Bool
    let onChange: (Bool) -> Void

    var body: some View {
        Toggle(isOn: Binding(get: { isOn }, set: onChange)) {
            HStack(spacing: Spacing.s) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(RoundedRectangle(cornerRadius: Radius.s, style: .continuous).fill(tint.opacity(0.16)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.bodyLarge)
                        .foregroundStyle(Palette.textPrimary)
                    Text(subtitle)
                        .font(.bodyMedium)
                        .foregroundStyle(Palette.textMuted)
                }
            }
        }
        .toggleStyle(.game(tint))
        .padding(Spacing.s)
        .background(RoundedRectangle(cornerRadius: Radius.m, style: .continuous).fill(Palette.surfaceRaised))
    }
}

#Preview {
    @Previewable @State var options = RecordingOptions()
    ZStack {
        AppBackground()
        RecordingSetupDialog(options: options,
                             onFaceCamChange: { options.isFaceCamEnabled = $0 },
                             onMicrophoneChange: { options.isMicrophoneEnabled = $0 },
                             onStart: {},
                             onDismiss: {})
    }
}
