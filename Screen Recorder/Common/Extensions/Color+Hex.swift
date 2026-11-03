import SwiftUI
import UIKit

extension Color {
    /// Creates an sRGB color from a 24-bit hex literal, e.g. `Color(hex: 0x7C4DFF)`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }

    /// A color that resolves to `light` or `dark` hex values based on the current interface style.
    ///
    /// UIKit calls the provider on whatever thread is rendering (often not the main thread),
    /// so it must stay nonisolated: a main-actor closure here crashes when the theme changes.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor(dynamicProvider: Self.dynamicProvider(light: light, dark: dark)))
    }

    nonisolated static func dynamicProvider(light: UInt32, dark: UInt32) -> @Sendable (UITraitCollection) -> UIColor {
        { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        }
    }
}

private extension UIColor {
    nonisolated convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}
