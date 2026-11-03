import SwiftUI

struct RootView: View {
    private let container: AppContainer
    @State private var router: AppRouter

    init(container: AppContainer) {
        self.container = container
        _router = State(initialValue: AppRouter(preferences: container.preferences))
    }

    var body: some View {
        ZStack {
            switch router.route {
            case .splash:
                SplashView(viewModel: container.makeSplashViewModel { router.splashDidFinish() })
                    .transition(.opacity)
            case .onboarding:
                OnboardingView(viewModel: container.makeOnboardingViewModel { router.onboardingDidFinish() })
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 1.04)),
                                        removal: .opacity.combined(with: .scale(scale: 0.96))))
            case .home:
                HomeView(viewModel: container.makeHomeViewModel())
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            }
        }
        .animation(.smooth(duration: 0.45), value: router.route)
    }
}

#Preview {
    RootView(container: .preview())
}
