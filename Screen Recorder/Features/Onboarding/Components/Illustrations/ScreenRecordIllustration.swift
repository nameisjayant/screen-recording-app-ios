import SwiftUI

/// Screen recording: a phone mid-recording a tiny platformer, with a pulsing REC button beside it.
struct ScreenRecordIllustration: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate = Date.now

    var body: some View {
        ZStack {
            Circle()
                .fill(Palette.record.opacity(0.18))
                .frame(width: 290, height: 290)

            IllustrationPhone(width: 150) {
                gameScene
            }
            .rotationEffect(.degrees(-6))

            recordButton
                .offset(x: 105, y: 105)

            TwinklingSparkle(color: Palette.sun, size: 28)
                .offset(x: -120, y: -110)
            TwinklingSparkle(color: Palette.primarySoft, size: 18, delay: 0.4)
                .offset(x: 120, y: -130)
            TwinklingSparkle(color: Palette.mint, size: 16, delay: 0.8)
                .offset(x: -125, y: 90)
        }
        .accessibilityHidden(true)
    }

    private var gameScene: some View {
        ZStack {
            LinearGradient(colors: [Palette.primary, Palette.primaryEdge], startPoint: .top, endPoint: .bottom)

            // Platforms and ground.
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 6).fill(Palette.mint).frame(width: 60, height: 12)
                    .offset(x: 30, y: -70)
                RoundedRectangle(cornerRadius: 6).fill(Palette.mint).frame(width: 50, height: 12)
                    .offset(x: -35, y: -40)
                Rectangle().fill(Palette.mintEdge).frame(height: 36)
            }

            // Bobbing coin.
            PhaseAnimator([false, true]) { up in
                Circle()
                    .fill(Palette.sun)
                    .overlay(Circle().stroke(Palette.sunEdge, lineWidth: 3))
                    .frame(width: 22, height: 22)
                    .offset(x: 30, y: up && !reduceMotion ? 25 : 35)
            } animation: { _ in .easeInOut(duration: 0.8) }

            // Jumping hero.
            PhaseAnimator([false, true]) { jump in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Palette.record)
                    .overlay(alignment: .top) {
                        HStack(spacing: 5) {
                            Circle().fill(.white).frame(width: 6, height: 6)
                            Circle().fill(.white).frame(width: 6, height: 6)
                        }
                        .padding(.top, 7)
                    }
                    .frame(width: 28, height: 28)
                    .offset(x: -35, y: jump && !reduceMotion ? 20 : 92)
            } animation: { jump in
                jump ? .easeOut(duration: 0.45) : .easeIn(duration: 0.45)
            }

            // REC indicator with a running timer.
            HStack(spacing: 5) {
                PhaseAnimator([1.0, 0.25]) { opacity in
                    Circle().fill(.white).frame(width: 8, height: 8).opacity(reduceMotion ? 1 : opacity)
                } animation: { _ in .easeInOut(duration: 0.6) }
                Text("REC").font(.badgeLabel)
                Text(timerInterval: startDate...startDate.addingTimeInterval(3600), countsDown: false)
                    .font(.badgeLabel)
                    .monospacedDigit()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(Palette.record))
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 36)
        }
    }

    private var recordButton: some View {
        ZStack {
            if !reduceMotion {
                PhaseAnimator([false, true]) { pulse in
                    Circle()
                        .stroke(Palette.record, lineWidth: 4)
                        .scaleEffect(pulse ? 1.5 : 1)
                        .opacity(pulse ? 0 : 0.8)
                } animation: { pulse in
                    pulse ? .easeOut(duration: 1.2) : .linear(duration: 0.01)
                }
            }
            Circle().fill(Palette.recordEdge).offset(y: 6)
            Circle().fill(Palette.record)
            Circle().fill(.white).frame(width: 26, height: 26)
        }
        .frame(width: 72, height: 72)
    }
}

#Preview {
    ScreenRecordIllustration()
        .frame(height: 330)
        .background(AppBackground())
}
