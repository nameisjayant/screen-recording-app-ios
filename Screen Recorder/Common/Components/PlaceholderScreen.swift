import SwiftUI

/// Temporary screen body for tabs whose UI hasn't been built yet.
struct PlaceholderScreen: View {
    let icon: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    var tint: Color = Palette.primary
    var titleIdentifier: String?

    var body: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 104, height: 104)
                .background(Circle().fill(tint.opacity(0.16)))
                .overlay(Circle().stroke(tint.opacity(0.5), lineWidth: 2))
            Text(title)
                .font(.displayMedium)
                .foregroundStyle(Palette.textPrimary)
                .accessibilityIdentifier(titleIdentifier ?? "")
            Text(message)
                .font(.bodyMedium)
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity)
    }
}
