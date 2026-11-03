import SwiftUI

extension Color {
    /// Creates an sRGB color from a 24-bit hex literal, e.g. `Color(hex: 0x7C4DFF)`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}
