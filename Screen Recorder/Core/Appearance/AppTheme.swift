import SwiftUI

/// User-selectable appearance. `system` follows the device's light / dark setting.
nonisolated enum AppTheme: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    /// The app was designed dark-first, so that's what new installs get.
    static let `default`: AppTheme = .dark

    /// `nil` lets SwiftUI follow the system setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    /// Window-level override; keeps UIKit-backed colors in sync, including when switching back to `system`.
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.stars.fill"
        }
    }
}
