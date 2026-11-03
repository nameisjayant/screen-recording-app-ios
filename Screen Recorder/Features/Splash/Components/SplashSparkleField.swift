import SwiftUI

/// Sparkles that burst out around the logo once it lands.
struct SplashSparkleField: View {
    let isVisible: Bool

    private let sparkles: [(x: CGFloat, y: CGFloat, size: CGFloat, color: Color)] = [
        (-130, -150, 26, Palette.sun),
        (140, -120, 18, Palette.mint),
        (-150, 40, 16, Palette.primarySoft),
        (150, 60, 28, Palette.sun),
        (-90, 150, 14, Palette.record),
        (100, 170, 16, Palette.primarySoft),
    ]

    var body: some View {
        ZStack {
            ForEach(Array(sparkles.enumerated()), id: \.offset) { index, sparkle in
                TwinklingSparkle(color: sparkle.color, size: sparkle.size, delay: Double(index) * 0.15)
                    .offset(x: isVisible ? sparkle.x : 0, y: isVisible ? sparkle.y : 0)
                    .scaleEffect(isVisible ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.15 + Double(index) * 0.04),
                               value: isVisible)
            }
        }
        .accessibilityHidden(true)
    }
}
