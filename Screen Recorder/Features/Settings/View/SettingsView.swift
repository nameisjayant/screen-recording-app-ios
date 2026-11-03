import SwiftUI

/// Settings tab. Placeholder until its UI is specified.
struct SettingsView: View {
    var body: some View {
        PlaceholderScreen(icon: HomeTab.settings.icon,
                          title: "Settings",
                          message: "App preferences will live here.",
                          tint: HomeTab.settings.accent,
                          titleIdentifier: "settings.title")
    }
}

#Preview {
    SettingsView().background(AppBackground(glow: Palette.mint))
}
