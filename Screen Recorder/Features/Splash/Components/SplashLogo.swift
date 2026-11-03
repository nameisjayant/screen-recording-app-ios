import SwiftUI

/// The app logo bouncing in on top of expanding "recording" pulse rings.
struct SplashLogo: View {
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if isVisible && !reduceMotion {
                PulseRings(color: Palette.record)
                    .frame(width: 150, height: 150)
            }

            PhaseAnimator([false, true]) { pulse in
                AppLogoMark(size: 150, recordPulse: pulse && !reduceMotion)
            } animation: { _ in
                .easeInOut(duration: 0.7)
            }
            .shadow(color: Palette.primary.opacity(0.6), radius: 30, y: 12)
            .scaleEffect(isVisible ? 1 : 0.2)
            .rotationEffect(.degrees(isVisible || reduceMotion ? 0 : -25))
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.55, dampingFraction: 0.55), value: isVisible)
        }
        .frame(width: 260, height: 260)
    }
}

private struct PulseRings: View {
    let color: Color
    @State private var expanding = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(color.opacity(0.7), lineWidth: 3)
                    .scaleEffect(expanding ? 1.9 : 1)
                    .opacity(expanding ? 0 : 0.9)
                    .animation(
                        .easeOut(duration: 1.8)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.6),
                        value: expanding
                    )
            }
        }
        .onAppear { expanding = true }
        .accessibilityHidden(true)
    }
}

#Preview {
    SplashLogo(isVisible: true)
        .background(Palette.background)
}
