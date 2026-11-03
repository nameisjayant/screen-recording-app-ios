import SwiftUI

/// Deep-space gradient with two soft glows; `glow` lets each screen tint the mood.
struct AppBackground: View {
    var glow: Color = Palette.primary

    var body: some View {
        ZStack {
            LinearGradient(colors: [Palette.background, Palette.backgroundDeep],
                           startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(glow.opacity(0.35))
                .frame(width: 420, height: 420)
                .blur(radius: 120)
                .offset(x: -140, y: -280)
            Circle()
                .fill(Palette.primary.opacity(0.25))
                .frame(width: 360, height: 360)
                .blur(radius: 120)
                .offset(x: 160, y: 320)
        }
        .ignoresSafeArea()
        .animation(.smooth(duration: 0.6), value: glow)
        .accessibilityHidden(true)
    }
}

#Preview {
    AppBackground(glow: Palette.record)
}
