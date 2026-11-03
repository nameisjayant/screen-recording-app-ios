import SwiftUI

/// A single onboarding page: animated illustration on top, feature copy below.
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.l) {
            illustration
                .frame(maxWidth: .infinity)
                .frame(height: 330)

            VStack(spacing: Spacing.s) {
                TagPill(text: page.feature, color: page.kind.accent)

                Text(page.title)
                    .font(.displayLarge)
                    .foregroundStyle(Palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(page.message)
                    .font(.bodyLarge)
                    .foregroundStyle(Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Spacing.l)

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var illustration: some View {
        switch page.kind {
        case .screenRecording: ScreenRecordIllustration()
        case .faceCam: FaceCamIllustration()
        case .commentary: CommentaryIllustration()
        }
    }
}

#Preview {
    OnboardingPageView(page: OnboardingPage.all[0])
        .background(AppBackground())
}
