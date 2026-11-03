import SwiftUI

/// Settings tab. Currently holds the appearance (light / dark) choice.
struct SettingsView: View {
    @State private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("Settings")
                    .font(.displayLarge)
                    .foregroundStyle(Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("settings.title")

                SettingsSection(title: "Appearance", icon: "paintpalette.fill", tint: HomeTab.settings.accent) {
                    ThemePicker(selection: viewModel.state.theme) { viewModel.send(.selectTheme($0)) }
                }
            }
            .padding(Spacing.l)
        }
        .scrollIndicators(.hidden)
    }
}

/// Titled card that groups related settings.
private struct SettingsSection<Content: View>: View {
    let title: LocalizedStringResource
    let icon: String
    let tint: Color
    @ViewBuilder var content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.l, style: .continuous)

        VStack(alignment: .leading, spacing: Spacing.m) {
            Label {
                Text(title)
                    .font(.displaySmall)
                    .foregroundStyle(Palette.textPrimary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(tint)
            }
            content
        }
        .padding(Spacing.m)
        .background {
            shape.fill(Palette.surface)
                .overlay(shape.stroke(Palette.outline, lineWidth: 2))
        }
        .background { shape.fill(Palette.backgroundDeep).offset(y: Motion.pressDepth) }
        .padding(.bottom, Motion.pressDepth)
    }
}

#Preview {
    SettingsView(viewModel: AppContainer.preview().makeSettingsViewModel())
        .background(AppBackground(glow: Palette.mint))
}
