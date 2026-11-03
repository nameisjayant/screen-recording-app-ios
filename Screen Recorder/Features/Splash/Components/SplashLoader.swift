import SwiftUI

/// Loading bar that fills while the splash finishes.
struct SplashLoader: View {
    let isLoading: Bool

    var body: some View {
        VStack(spacing: Spacing.s) {
            GameProgressBar(progress: isLoading ? 1 : 0, tint: Palette.sun, height: 18)
                .animation(.easeInOut(duration: 1.15), value: isLoading)
            Text("Getting things ready…")
                .font(.label)
                .kerning(1)
                .textCase(.uppercase)
                .foregroundStyle(Palette.textMuted)
        }
        .opacity(isLoading ? 1 : 0)
        .animation(.easeOut(duration: 0.25), value: isLoading)
    }
}

#Preview {
    SplashLoader(isLoading: true)
        .padding()
        .background(Palette.background)
}
