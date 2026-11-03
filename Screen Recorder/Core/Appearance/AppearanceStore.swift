import Observation

/// App-wide appearance state. The app root reads `theme` to set the color scheme;
/// Settings changes it. Every change is persisted to `AppPreferences`.
@Observable
final class AppearanceStore {
    private(set) var theme: AppTheme

    @ObservationIgnored private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
        self.theme = preferences.theme
    }

    func setTheme(_ theme: AppTheme) {
        guard theme != self.theme else { return }
        self.theme = theme
        preferences.theme = theme
    }
}
