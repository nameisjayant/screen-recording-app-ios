import SwiftUI

/// "Arcade Pop" palette. Each bright face color has a `…Edge` shade used for the 3D base of chunky controls.
enum Palette {
    // Surfaces
    static let background = Color(hex: 0x0F0B2E)
    static let backgroundDeep = Color(hex: 0x07051A)
    static let surface = Color(hex: 0x1C1747)
    static let surfaceRaised = Color(hex: 0x292261)
    static let outline = Color(hex: 0x3A3278)

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
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0xC4BEF0)
    static let textMuted = Color(hex: 0x8A83C2)
}
