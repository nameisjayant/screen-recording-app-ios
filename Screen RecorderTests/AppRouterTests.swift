import Testing
@testable import Screen_Recorder

@MainActor
struct AppRouterTests {
    @Test func firstLaunchGoesToOnboarding() {
        let router = AppRouter(preferences: InMemoryAppPreferences())

        router.splashDidFinish()

        #expect(router.route == .onboarding)
    }

    @Test func returningUserSkipsOnboarding() {
        let router = AppRouter(preferences: InMemoryAppPreferences(hasCompletedOnboarding: true))

        router.splashDidFinish()

        #expect(router.route == .home)
    }

    @Test func finishingOnboardingIsRemembered() {
        let preferences = InMemoryAppPreferences()
        let router = AppRouter(preferences: preferences)

        router.onboardingDidFinish()

        #expect(router.route == .home)
        #expect(preferences.hasCompletedOnboarding)
    }
}
