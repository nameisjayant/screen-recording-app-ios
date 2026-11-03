import SwiftUI

/// "Arcade Pop" palette. Each bright face color has a `…Edge` shade used for the 3D base of chunky controls.
///
/// Surfaces and text adapt to light / dark mode; brand colors and `ink` stay the same in both.
enum Palette {
    // Surfaces
    static let background = Color(light: 0xF6F4FF, dark: 0x0F0B2E)
    static let backgroundDeep = Color(light: 0xD9D2F7, dark: 0x07051A)
    static let surface = Color(light: 0xFFFFFF, dark: 0x1C1747)
    static let surfaceRaised = Color(light: 0xEFEBFF, dark: 0x292261)
    static let outline = Color(light: 0xD4CCF5, dark: 0x3A3278)

    // Brand
    static let primary = Color(hex: 0x7C4DFF)
    static let primaryEdge = Color(hex: 0x4A1FCF)
    static let primarySoft = Color(hex: 0xB9A3FF)

    static let record = Color(hex: 0xFF4D6D)
    static let recordEdge = Color(hex: 0xC2183B)

    static let sun = Color(hex: 0xFFC93C)
    static let sunEdge = Color(hex: 0xD69A12)

    static let mint = Color(hex: 0x2DE1C2)
    static let mintEdge = Color(hex: 0x1E9E8A)

    // Content
    static let ink = Color(hex: 0x13104A)
    static let textPrimary = Color(light: 0x13104A, dark: 0xFFFFFF)
    static let textSecondary = Color(light: 0x4A4382, dark: 0xC4BEF0)
    static let textMuted = Color(light: 0x7A73B0, dark: 0x8A83C2)
}
