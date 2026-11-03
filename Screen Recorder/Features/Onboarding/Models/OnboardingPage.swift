import Foundation

/// One onboarding page, introducing a single feature.
nonisolated struct OnboardingPage: Identifiable, Equatable, Sendable {
    enum Kind: CaseIterable {
        case screenRecording
        case faceCam
        case commentary
    }

    let kind: Kind
    let feature: LocalizedStringResource
    let title: LocalizedStringResource
    let message: LocalizedStringResource

    var id: Kind { kind }

    static func == (lhs: OnboardingPage, rhs: OnboardingPage) -> Bool {
        lhs.kind == rhs.kind
    }
}

extension OnboardingPage {
    static let all: [OnboardingPage] = [
        OnboardingPage(
            kind: .screenRecording,
            feature: "Screen Recording",
            title: "Record Your Screen",
            message: "Capture anything on your screen in one tap — gameplay, tutorials, app demos or bugs. Smooth, crisp and ready to share."
        ),
        OnboardingPage(
            kind: .faceCam,
            feature: "Face Cam",
            title: "Add Your Face Cam",
            message: "Show a live bubble of yourself on top of the recording so viewers see your reactions as they happen."
        ),
        OnboardingPage(
            kind: .commentary,
            feature: "Commentary",
            title: "Talk While You Record",
            message: "Add voice commentary as you record. Your voice is captured right alongside the screen, perfectly in sync."
        ),
    ]
}
