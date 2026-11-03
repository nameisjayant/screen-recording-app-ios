import SwiftUI

/// In-app rendition of the app icon. Geometry matches `scripts/generate_app_icon.swift`
/// (drawn on a 1024pt canvas, then scaled), so the splash logo and home-screen icon are identical.
struct AppLogoMark: View {
    var size: CGFloat = 120
    /// Lets the splash animate the record dot independently of the tile.
    var recordPulse: Bool = false

    private let canvas: CGFloat = 1024

    var body: some View {
        artwork
            .frame(width: canvas, height: canvas)
            .scaleEffect(size / canvas)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous))
            .accessibilityLabel(Text("RecQuest logo"))
    }

    private var artwork: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x8F5BFF), Palette.primaryEdge, Color(hex: 0x22105E)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Color.white.opacity(0.28), .clear],
                           center: UnitPoint(x: 0.2, y: 0.12), startRadius: 0, endRadius: 520)

            ZStack {
                RoundedRectangle(cornerRadius: 120, style: .continuous)
                    .fill(Palette.primarySoft)
                    .frame(width: 640, height: 520)
                    .offset(y: 34)
                RoundedRectangle(cornerRadius: 120, style: .continuous)
                    .fill(.white)
                    .frame(width: 640, height: 520)

                Circle()
                    .stroke(Palette.record.opacity(0.25), lineWidth: 34)
                    .frame(width: 330, height: 330)
                    .scaleEffect(recordPulse ? 1.08 : 1)
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: 0xFF7A8F), Color(hex: 0xFF3355)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 236, height: 236)
                    .scaleEffect(recordPulse ? 0.9 : 1)
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 62, height: 62)
                    .offset(x: -54, y: -54)

                SparkleShape().fill(Palette.sun)
                    .frame(width: 170, height: 170)
                    .offset(x: 300, y: -250)
                SparkleShape().fill(Palette.sun)
                    .frame(width: 80, height: 80)
                    .offset(x: 205, y: -330)

                FaceBubble(size: 250)
                    .offset(x: 270, y: 250)
            }
            .offset(x: -36, y: 8)
        }
    }
}

#Preview {
    AppLogoMark(size: 200)
        .padding()
        .background(Palette.background)
}
