import SwiftUI

extension OnboardingPage.Kind {
    /// Accent used for the page's glow, tag and progress.
    var accent: Color {
        switch self {
        case .screenRecording: Palette.record
        case .faceCam: Palette.mint
        case .commentary: Palette.sun
        }
    }
}
