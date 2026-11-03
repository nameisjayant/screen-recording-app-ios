import SwiftUI

/// Title whose letters drop in one by one with a bouncy stagger.
struct SplashTitle: View {
    let text: String
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                Text(String(letter))
                    .font(.displayHero)
                    .foregroundStyle(index < 3 ? Palette.record : Palette.textPrimary)
                    .offset(y: isVisible || reduceMotion ? 0 : -60)
                    .scaleEffect(isVisible ? 1 : 0.4, anchor: .bottom)
                    .opacity(isVisible ? 1 : 0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.5).delay(Double(index) * 0.045),
                        value: isVisible
                    )
            }
        }
        .shadow(color: Palette.backgroundDeep.opacity(0.8), radius: 0, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(text))
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    SplashTitle(text: "RecQuest", isVisible: true)
        .padding()
        .background(Palette.background)
}
