import Testing
@testable import Screen_Recorder

@MainActor
struct SettingsViewModelTests {
    @Test func defaultsToDarkTheme() {
        let viewModel = SettingsViewModel(appearance: AppearanceStore(preferences: InMemoryAppPreferences()))

        #expect(viewModel.state.theme == .dark)
    }

    @Test func loadsSavedTheme() {
        let preferences = InMemoryAppPreferences(theme: .light)
        let viewModel = SettingsViewModel(appearance: AppearanceStore(preferences: preferences))

        #expect(viewModel.state.theme == .light)
    }

    @Test func selectingThemeUpdatesStoreAndPreferences() {
        let preferences = InMemoryAppPreferences()
        let appearance = AppearanceStore(preferences: preferences)
        let viewModel = SettingsViewModel(appearance: appearance)

        viewModel.send(.selectTheme(.light))
        #expect(viewModel.state.theme == .light)
        #expect(appearance.theme == .light)
        #expect(preferences.theme == .light)

        viewModel.send(.selectTheme(.system))
        #expect(appearance.theme.colorScheme == nil)
        #expect(preferences.theme == .system)
    }
}
