import SwiftUI

/// Four-point star used for decorative sparkles across the app.
struct SparkleShape: Shape {
    var innerRatio: CGFloat = 0.28

    nonisolated func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        for index in 0..<8 {
            let angle = Double(index) * .pi / 4 - .pi / 2
            let length = index.isMultiple(of: 2) ? radius : radius * innerRatio
            let point = CGPoint(x: center.x + cos(angle) * length, y: center.y + sin(angle) * length)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// A sparkle that gently twinkles (scales and rotates) forever.
struct TwinklingSparkle: View {
    var color: Color = Palette.sun
    var size: CGFloat = 20
    var delay: Double = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            sparkle
        } else {
            PhaseAnimator([false, true]) { twinkle in
                sparkle
                    .scaleEffect(twinkle ? 1 : 0.55)
                    .rotationEffect(.degrees(twinkle ? 20 : -10))
                    .opacity(twinkle ? 1 : 0.6)
            } animation: { _ in
                .easeInOut(duration: 0.9).delay(delay)
            }
        }
    }

    private var sparkle: some View {
        SparkleShape()
            .fill(color)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
