import Foundation

/// Small key-value settings the app persists between launches.
protocol AppPreferences: AnyObject {
    var hasCompletedOnboarding: Bool { get set }
}

final class UserDefaultsAppPreferences: AppPreferences {
    private enum Key {
        static let hasCompletedOnboarding = "preferences.hasCompletedOnboarding"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }
}

/// Non-persistent store for previews, unit tests and UI tests.
final class InMemoryAppPreferences: AppPreferences {
    var hasCompletedOnboarding: Bool

    init(hasCompletedOnboarding: Bool = false) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
