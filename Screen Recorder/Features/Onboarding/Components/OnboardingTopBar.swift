import SwiftUI

/// Step progress plus a skip action.
struct OnboardingTopBar: View {
    let currentIndex: Int
    let pageCount: Int
    let accent: Color
    let showsSkip: Bool
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: Spacing.m) {
            SegmentedProgressBar(count: pageCount, current: currentIndex, tint: accent)
                .frame(maxWidth: 140)
            Spacer()
            Button("Skip", action: onSkip)
                .font(.buttonLabel)
                .foregroundStyle(Palette.textSecondary)
                .opacity(showsSkip ? 1 : 0)
                .disabled(!showsSkip)
                .accessibilityIdentifier("onboarding.skip")
        }
        .frame(minHeight: 44)
        .padding(.horizontal, Spacing.l)
    }
}
