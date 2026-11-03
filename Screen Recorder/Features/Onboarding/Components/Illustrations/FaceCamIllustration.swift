import SwiftUI

/// Face cam: the face-cam bubble roams over a recording while reactions float up.
struct FaceCamIllustration: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum BubbleSpot: CaseIterable {
        case topTrailing, bottomTrailing, bottomLeading

        var offset: CGSize {
            switch self {
            case .topTrailing: CGSize(width: 30, height: -70)
            case .bottomTrailing: CGSize(width: 30, height: 90)
            case .bottomLeading: CGSize(width: -30, height: 90)
            }
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Palette.mint.opacity(0.16))
                .frame(width: 290, height: 290)

            IllustrationPhone(width: 150) {
                ZStack {
                    recordingContent
                    roamingBubble
                }
            }
            .rotationEffect(.degrees(5))

            cameraChip
                .offset(x: -110, y: -100)

            FloatingReaction(emoji: "😮", delay: 0)
                .offset(x: 115, y: -40)
            FloatingReaction(emoji: "🔥", delay: 0.7)
                .offset(x: 130, y: 60)
            FloatingReaction(emoji: "😂", delay: 1.4)
                .offset(x: -120, y: 80)
        }
        .accessibilityHidden(true)
    }

    private var recordingContent: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10).fill(Palette.primary).frame(height: 70)
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10).fill(Palette.record.opacity(0.85))
                RoundedRectangle(cornerRadius: 10).fill(Palette.sun.opacity(0.85))
            }
            .frame(height: 60)
            RoundedRectangle(cornerRadius: 10).fill(Palette.outline).frame(height: 14)
            RoundedRectangle(cornerRadius: 10).fill(Palette.outline).frame(width: 80, height: 14)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .padding(14)
        .padding(.top, 30)
        .background(Palette.surface)
    }

    @ViewBuilder
    private var roamingBubble: some View {
        if reduceMotion {
            FaceBubble(size: 62).offset(BubbleSpot.bottomTrailing.offset)
        } else {
            PhaseAnimator(BubbleSpot.allCases) { spot in
                FaceBubble(size: 62).offset(spot.offset)
            } animation: { _ in
                .spring(response: 0.7, dampingFraction: 0.65).delay(0.9)
            }
        }
    }

    private var cameraChip: some View {
        Image(systemName: "video.fill")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(Palette.ink)
            .frame(width: 56, height: 56)
            .background(Circle().fill(Palette.mint))
            .background(Circle().fill(Palette.mintEdge).offset(y: 5))
    }
}

/// Emoji that drifts upward and fades, on a loop.
private struct FloatingReaction: View {
    let emoji: String
    let delay: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            Text(emoji).font(.system(size: 34))
        } else {
            PhaseAnimator([false, true]) { risen in
                Text(emoji)
                    .font(.system(size: 34))
                    .offset(y: risen ? -40 : 10)
                    .scaleEffect(risen ? 1.1 : 0.6)
                    .opacity(risen ? 0 : 1)
            } animation: { risen in
                risen ? .easeOut(duration: 1.6).delay(delay) : .linear(duration: 0.01)
            }
        }
    }
}

#Preview {
    FaceCamIllustration()
        .frame(height: 330)
        .background(AppBackground())
}
