import Observation

/// Ordered stages of the splash animation. The view animates purely from the current phase.
nonisolated enum SplashPhase: Int, Comparable, Sendable {
    case idle
    case logo
    case title
    case loading
    case finished

    static func < (lhs: SplashPhase, rhs: SplashPhase) -> Bool { lhs.rawValue < rhs.rawValue }
}

nonisolated struct SplashState: Equatable, Sendable {
    var phase: SplashPhase = .idle
    var showsBetaBadge = false
}

enum SplashIntent {
    /// User tapped the splash to jump straight in.
    case skipRequested
}

@Observable
final class SplashViewModel: ViewModel {
    /// Each phase starts after the given delay from the previous one.
    static let timeline: [(phase: SplashPhase, delay: Duration)] = [
        (.logo, .milliseconds(100)),
        (.title, .milliseconds(550)),
        (.loading, .milliseconds(450)),
        (.finished, .milliseconds(1300)),
    ]

    private(set) var state: SplashState

    @ObservationIgnored private let sleep: (Duration) async throws -> Void
    @ObservationIgnored private let onFinish: () -> Void
    @ObservationIgnored private var hasFinished = false

    init(
        environment: AppEnvironment,
        sleep: @escaping (Duration) async throws -> Void = { try await Task.sleep(for: $0) },
        onFinish: @escaping () -> Void
    ) {
        self.state = SplashState(showsBetaBadge: environment.isBeta)
        self.sleep = sleep
        self.onFinish = onFinish
    }

    func send(_ intent: SplashIntent) {
        switch intent {
        case .skipRequested:
            guard state.phase >= .title else { return }
            finish()
        }
    }

    /// Plays the splash timeline. Call from `.task` so SwiftUI cancels it if the view goes away.
    func start() async {
        guard state.phase == .idle else { return }
        for step in Self.timeline {
            do {
                try await sleep(step.delay)
            } catch {
                return
            }
            guard !hasFinished else { return }
            if step.phase == .finished {
                finish()
            } else {
                state.phase = step.phase
            }
        }
    }

    private func finish() {
        guard !hasFinished else { return }
        hasFinished = true
        state.phase = .finished
        onFinish()
    }
}
