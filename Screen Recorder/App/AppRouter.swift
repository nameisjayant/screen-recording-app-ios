import Observation

enum AppRoute: Equatable {
    case splash
    case onboarding
    case home
}

/// Drives the top-level flow: splash → onboarding (first launch only) → home.
@Observable
final class AppRouter {
    private(set) var route: AppRoute = .splash

    @ObservationIgnored private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
    }

    func splashDidFinish() {
        route = preferences.hasCompletedOnboarding ? .home : .onboarding
    }

    func onboardingDidFinish() {
        preferences.hasCompletedOnboarding = true
        route = .home
    }
}
