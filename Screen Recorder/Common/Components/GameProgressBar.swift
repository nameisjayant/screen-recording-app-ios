import SwiftUI

/// Chunky, glossy progress bar with a game-style look.
struct GameProgressBar: View {
    /// 0...1
    let progress: Double
    var tint: Color = Palette.sun
    var height: CGFloat = 16

    var body: some View {
        GeometryReader { proxy in
            let clamped = min(max(progress, 0), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.surface)
                Capsule().stroke(Palette.outline, lineWidth: 2)
                Capsule()
                    .fill(tint)
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(.white.opacity(0.35))
                            .frame(height: height * 0.25)
                            .padding(.horizontal, height * 0.4)
                            .padding(.top, height * 0.18)
                    }
                    .frame(width: max(height, proxy.size.width * clamped))
                    .opacity(clamped > 0 ? 1 : 0)
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityValue(Text(progress, format: .percent.precision(.fractionLength(0))))
    }
}

/// Segmented step indicator (one segment per step), used for paged flows.
struct SegmentedProgressBar: View {
    let count: Int
    let current: Int
    var tint: Color = Palette.sun

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? tint : Palette.surface)
                    .overlay(Capsule().stroke(index <= current ? .clear : Palette.outline, lineWidth: 1.5))
                    .frame(height: 10)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: current)
        .accessibilityElement()
        .accessibilityLabel(Text("Step \(current + 1) of \(count)"))
    }
}

#Preview {
    VStack(spacing: Spacing.l) {
        GameProgressBar(progress: 0.65)
        SegmentedProgressBar(count: 3, current: 1)
    }
    .padding()
    .background(Palette.background)
}
