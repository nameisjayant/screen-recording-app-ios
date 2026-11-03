import SwiftUI

/// The friendly face-cam mascot: a mint bubble with a smile, raised on a 3D base.
struct FaceBubble: View {
    var size: CGFloat = 80
    var ringColor: Color = .white

    var body: some View {
        let unit = size / 250
        ZStack {
            Circle().fill(Palette.mintEdge).offset(y: 16 * unit)
            Circle().fill(Palette.mint)
            Circle().stroke(ringColor, lineWidth: 18 * unit)
            HStack(spacing: 46 * unit) {
                Capsule().frame(width: 26 * unit, height: 40 * unit)
                Capsule().frame(width: 26 * unit, height: 40 * unit)
            }
            .foregroundStyle(Palette.ink)
            .offset(y: -20 * unit)
            SmileShape()
                .stroke(Palette.ink, style: StrokeStyle(lineWidth: 18 * unit, lineCap: .round))
                .frame(width: 92 * unit, height: 46 * unit)
                .offset(y: 42 * unit)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct SmileShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: CGPoint(x: rect.midX, y: rect.maxY * 1.4))
        return path
    }
}

#Preview {
    FaceBubble(size: 160)
        .padding()
        .background(Palette.background)
}
