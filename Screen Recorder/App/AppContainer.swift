import Foundation

/// Composition root: owns shared dependencies and builds feature view models.
///
/// Features never reach for singletons; they receive what they need from here,
/// so swapping an implementation (e.g. for tests or previews) is a one-line change.
final class AppContainer {
    let environment: AppEnvironment
    let preferences: AppPreferences

    init(environment: AppEnvironment = .current, preferences: AppPreferences) {
        self.environment = environment
        self.preferences = preferences
    }

    static func live() -> AppContainer {
        let preferences: AppPreferences = AppEnvironment.isUITesting
            ? InMemoryAppPreferences()
            : UserDefaultsAppPreferences()
        return AppContainer(preferences: preferences)
    }

    static func preview(hasCompletedOnboarding: Bool = false) -> AppContainer {
        AppContainer(preferences: InMemoryAppPreferences(hasCompletedOnboarding: hasCompletedOnboarding))
    }

    // MARK: - Feature factories

    func makeSplashViewModel(onFinish: @escaping () -> Void) -> SplashViewModel {
        SplashViewModel(environment: environment, onFinish: onFinish)
    }

    func makeOnboardingViewModel(onFinish: @escaping () -> Void) -> OnboardingViewModel {
        OnboardingViewModel(onFinish: onFinish)
    }
}
