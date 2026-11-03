import SwiftUI

/// Bottom bar destinations. `recorder` is shown as the raised "+" button in the middle.
nonisolated enum HomeTab: String, CaseIterable, Sendable {
    case dashboard
    case recorder
    case settings

    var title: LocalizedStringResource {
        switch self {
        case .dashboard: "Dashboard"
        case .recorder: "Record"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "square.grid.2x2.fill"
        case .recorder: "plus"
        case .settings: "gearshape.fill"
        }
    }

    @MainActor var accent: Color {
        switch self {
        case .dashboard: Palette.primary
        case .recorder: Palette.record
        case .settings: Palette.mint
        }
    }
}
