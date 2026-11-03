import SwiftUI

/// Small rounded label, e.g. a feature name or "BETA".
struct TagPill: View {
    let text: LocalizedStringResource
    var color: Color = Palette.primary

    var body: some View {
        Text(text)
            .font(.label)
            .kerning(1.2)
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xxs + 1)
            .background(Capsule().fill(color.opacity(0.16)))
            .overlay(Capsule().stroke(color.opacity(0.5), lineWidth: 1.5))
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        TagPill(text: "Face Cam", color: Palette.mint)
        TagPill(text: "Beta", color: Palette.sun)
    }
    .padding()
    .background(Palette.background)
}
