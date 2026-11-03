import SwiftUI

/// Commentary: a chunky mic with a live voice waveform and speech bubbles.
struct CommentaryIllustration: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .fill(Palette.sun.opacity(0.14))
                .frame(width: 290, height: 290)
            Circle()
                .stroke(Palette.sun.opacity(0.25), lineWidth: 2)
                .frame(width: 210, height: 210)

            HStack(spacing: 22) {
                VoiceWaveform(barCount: 4, color: Palette.mint, mirrored: true)
                microphone
                VoiceWaveform(barCount: 4, color: Palette.mint, mirrored: false)
            }

            FloatingBubble(text: "Hello!", color: Palette.sun, tailOnLeading: true, delay: 0)
                .offset(x: -85, y: -115)
            FloatingBubble(text: "Watch this!", color: Palette.mint, tailOnLeading: false, delay: 0.5)
                .offset(x: 80, y: -95)
            FloatingBubble(text: "Pro tip", color: Palette.primarySoft, tailOnLeading: true, delay: 1)
                .offset(x: 70, y: 115)

            TwinklingSparkle(color: Palette.sun, size: 22, delay: 0.3)
                .offset(x: -120, y: 90)
        }
        .accessibilityHidden(true)
    }

    private var microphone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous).fill(Palette.recordEdge).offset(y: 8)
            RoundedRectangle(cornerRadius: 34, style: .continuous).fill(Palette.record)
            Image(systemName: "mic.fill")
                .font(.system(size: 54, weight: .bold))
                .foregroundStyle(.white)
            if !reduceMotion {
                PhaseAnimator([false, true]) { live in
                    Circle().fill(.white).frame(width: 12, height: 12)
                        .opacity(live ? 1 : 0.3)
                } animation: { _ in .easeInOut(duration: 0.6) }
                .offset(x: 38, y: -38)
            }
        }
        .frame(width: 112, height: 112)
    }
}

/// Bars that dance like a live voice level meter.
private struct VoiceWaveform: View {
    let barCount: Int
    let color: Color
    let mirrored: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 6) {
                ForEach(0..<barCount, id: \.self) { index in
                    let order = mirrored ? barCount - 1 - index : index
                    let falloff = 1 - Double(order) * 0.18
                    let wave = (sin(time * 6 + Double(index) * 1.3) + 1) / 2
                    Capsule()
                        .fill(color.opacity(falloff))
                        .frame(width: 8, height: CGFloat(18 + wave * 52 * falloff))
                }
            }
            .frame(height: 74)
        }
    }
}

private struct FloatingBubble: View {
    let text: LocalizedStringKey
    let color: Color
    let tailOnLeading: Bool
    let delay: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        PhaseAnimator([false, true]) { up in
            SpeechBubble(text: text, color: color, tailOnLeading: tailOnLeading)
                .offset(y: up && !reduceMotion ? -8 : 0)
                .rotationEffect(.degrees(up && !reduceMotion ? (tailOnLeading ? -4 : 4) : 0))
        } animation: { _ in
            .easeInOut(duration: 1.2).delay(delay)
        }
    }
}

#Preview {
    CommentaryIllustration()
        .frame(height: 330)
        .background(AppBackground())
}
