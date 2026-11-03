import SwiftUI

/// Bottom bar destinations. The middle microphone button isn't a tab: it opens the recording setup dialog.
nonisolated enum HomeTab: String, CaseIterable, Sendable {
    case dashboard
    case settings

    var title: LocalizedStringResource {
        switch self {
        case .dashboard: "Dashboard"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "square.grid.2x2.fill"
        case .settings: "gearshape.fill"
        }
    }

    @MainActor var accent: Color {
        switch self {
        case .dashboard: Palette.primary
        case .settings: Palette.mint
        }
    }
}
