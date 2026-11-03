import SwiftUI

@main
struct RecQuestApp: App {
    @State private var container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .preferredColorScheme(container.appearance.theme.colorScheme)
                .tint(Palette.primary)
                .onChange(of: container.appearance.theme, initial: true) { _, theme in
                    applyWindowStyle(theme)
                }
        }
    }

    private func applyWindowStyle(_ theme: AppTheme) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.overrideUserInterfaceStyle = theme.userInterfaceStyle }
    }
}
