import SwiftUI

@main
struct RecQuestApp: App {
    @State private var container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .preferredColorScheme(.dark)
                .tint(Palette.primary)
        }
    }
}
