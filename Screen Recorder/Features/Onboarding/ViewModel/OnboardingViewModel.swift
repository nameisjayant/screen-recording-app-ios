import Observation

nonisolated struct OnboardingState: Equatable, Sendable {
    let pages: [OnboardingPage]
    var currentIndex = 0

    var currentPage: OnboardingPage { pages[currentIndex] }
    var isLastPage: Bool { currentIndex == pages.count - 1 }
}

enum OnboardingIntent {
    case selectPage(Int)
    case next
    case skip
}

@Observable
final class OnboardingViewModel: ViewModel {
    private(set) var state: OnboardingState

    @ObservationIgnored private let onFinish: () -> Void
    @ObservationIgnored private var hasFinished = false

    init(pages: [OnboardingPage] = OnboardingPage.all, onFinish: @escaping () -> Void) {
        precondition(!pages.isEmpty, "Onboarding needs at least one page")
        self.state = OnboardingState(pages: pages)
        self.onFinish = onFinish
    }

    func send(_ intent: OnboardingIntent) {
        switch intent {
        case .selectPage(let index):
            select(index)
        case .next:
            if state.isLastPage {
                finish()
            } else {
                select(state.currentIndex + 1)
            }
        case .skip:
            finish()
        }
    }

    private func select(_ index: Int) {
        guard state.pages.indices.contains(index) else { return }
        state.currentIndex = index
    }

    private func finish() {
        guard !hasFinished else { return }
        hasFinished = true
        onFinish()
    }
}
