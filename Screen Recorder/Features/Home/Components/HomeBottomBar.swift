import SwiftUI

/// Chunky game-style bottom bar: two side tabs and a raised record "+" button in the middle.
struct HomeBottomBar: View {
    let selectedTab: HomeTab
    let onSelect: (HomeTab) -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.l, style: .continuous)

        HStack(alignment: .bottom, spacing: 0) {
            HomeTabItem(tab: .dashboard, isSelected: selectedTab == .dashboard) { onSelect(.dashboard) }
            RecordTabButton(isSelected: selectedTab == .recorder) { onSelect(.recorder) }
                .frame(maxWidth: .infinity)
            HomeTabItem(tab: .settings, isSelected: selectedTab == .settings) { onSelect(.settings) }
        }
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, Spacing.xs)
        .background {
            shape.fill(Palette.surface)
                .overlay(shape.stroke(Palette.outline, lineWidth: 2))
        }
        .background { shape.fill(Palette.backgroundDeep).offset(y: Motion.pressDepth) }
        .padding(.horizontal, Spacing.m)
        .padding(.bottom, Spacing.xs)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

/// Side tab: icon in a pill that lights up with the tab's accent when selected.
private struct HomeTabItem: View {
    let tab: HomeTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? tab.accent : Palette.textMuted)
                    .frame(width: 56, height: 34)
                    .background {
                        Capsule()
                            .fill(tab.accent.opacity(isSelected ? 0.18 : 0))
                    }
                    .scaleEffect(isSelected ? 1.08 : 1)
                Text(tab.title)
                    .font(.label)
                    .foregroundStyle(isSelected ? Palette.textPrimary : Palette.textMuted)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("home.tab.\(tab.rawValue)")
    }
}

/// Raised round record button that pokes out above the bar.
private struct RecordTabButton: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: HomeTab.recorder.icon)
                .font(.system(size: 28, weight: .heavy))
                .rotationEffect(.degrees(isSelected ? 90 : 0))
        }
        .buttonStyle(RecordButtonStyle(isSelected: isSelected))
        .offset(y: -Spacing.l)
        .padding(.bottom, -Spacing.l)
        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: isSelected)
        .accessibilityLabel(Text(HomeTab.recorder.title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("home.tab.\(HomeTab.recorder.rawValue)")
    }
}

private struct RecordButtonStyle: ButtonStyle {
    let isSelected: Bool
    private let size: CGFloat = 66

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        configuration.label
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                Circle().fill(Palette.record)
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(.white.opacity(0.25))
                            .frame(width: size * 0.45, height: 6)
                            .padding(.top, Spacing.xs)
                    }
            }
            .offset(y: pressed ? Motion.pressDepth : 0)
            .background { Circle().fill(Palette.recordEdge).offset(y: Motion.pressDepth) }
            .padding(.bottom, Motion.pressDepth)
            .padding(5)
            .background {
                // Ring in the bar's color so the button looks "cut into" the bar.
                Circle().fill(Palette.surface)
                    .overlay(Circle().stroke(isSelected ? Palette.record : Palette.outline, lineWidth: 2))
            }
            .shadow(color: Palette.record.opacity(isSelected ? 0.55 : 0.3), radius: 14, y: 4)
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
    }
}

#Preview {
    @Previewable @State var tab: HomeTab = .dashboard
    VStack {
        Spacer()
        HomeBottomBar(selectedTab: tab) { tab = $0 }
    }
    .background(AppBackground())
}
