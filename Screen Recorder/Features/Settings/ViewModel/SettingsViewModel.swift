import Observation

nonisolated struct SettingsState: Equatable, Sendable {
    var theme: AppTheme
}

enum SettingsIntent {
    case selectTheme(AppTheme)
}

@Observable
final class SettingsViewModel: ViewModel {
    @ObservationIgnored private let appearance: AppearanceStore

    /// Derived from the shared `AppearanceStore` so the whole app stays in sync with one source of truth.
    var state: SettingsState {
        SettingsState(theme: appearance.theme)
    }

    init(appearance: AppearanceStore) {
        self.appearance = appearance
    }

    func send(_ intent: SettingsIntent) {
        switch intent {
        case .selectTheme(let theme):
            appearance.setTheme(theme)
        }
    }
}
