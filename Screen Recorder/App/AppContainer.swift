import Foundation

/// Composition root: owns shared dependencies and builds feature view models.
///
/// Features never reach for singletons; they receive what they need from here,
/// so swapping an implementation (e.g. for tests or previews) is a one-line change.
final class AppContainer {
    let environment: AppEnvironment
    let preferences: AppPreferences
    let appearance: AppearanceStore
    let recorder: ScreenRecordingController
    let recordingLibrary: RecordingLibrary

    init(environment: AppEnvironment = .current, preferences: AppPreferences) {
        self.environment = environment
        self.preferences = preferences
        self.appearance = AppearanceStore(preferences: preferences)
        self.recorder = ScreenRecordingController(preferences: preferences)
        self.recordingLibrary = FileRecordingLibrary()
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

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(preferences: preferences, recorder: recorder)
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(library: recordingLibrary, recorder: recorder)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(appearance: appearance)
    }
}
