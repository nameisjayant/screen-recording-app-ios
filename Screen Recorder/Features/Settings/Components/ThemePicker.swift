import SwiftUI

/// Three chunky cards (System / Light / Dark); the selected one is raised in the accent color.
struct ThemePicker: View {
    let selection: AppTheme
    let onSelect: (AppTheme) -> Void

    var body: some View {
        HStack(spacing: Spacing.s) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                ThemeOption(theme: theme, isSelected: theme == selection) { onSelect(theme) }
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

private struct ThemeOption: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: theme.icon)
                    .font(.system(size: 22, weight: .bold))
                Text(theme.title)
                    .font(.label)
            }
            .frame(maxWidth: .infinity, minHeight: 76)
        }
        .buttonStyle(ThemeOptionStyle(isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("settings.theme.\(theme.rawValue)")
    }
}

private struct ThemeOptionStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
        let pressed = configuration.isPressed

        configuration.label
            .foregroundStyle(isSelected ? .white : Palette.textSecondary)
            .background {
                shape.fill(isSelected ? Palette.primary : Palette.surfaceRaised)
                    .overlay(shape.stroke(isSelected ? Palette.primary : Palette.outline, lineWidth: 2))
            }
            .offset(y: pressed ? Motion.pressDepth : 0)
            .background {
                shape.fill(isSelected ? Palette.primaryEdge : Palette.backgroundDeep).offset(y: Motion.pressDepth)
            }
            .padding(.bottom, Motion.pressDepth)
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    @Previewable @State var theme: AppTheme = .dark
    ThemePicker(selection: theme) { theme = $0 }
        .padding()
        .background(Palette.background)
        .preferredColorScheme(theme.colorScheme)
}
