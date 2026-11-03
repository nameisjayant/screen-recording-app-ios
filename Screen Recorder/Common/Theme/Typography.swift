import SwiftUI

/// Bundled fonts: **Fredoka** (rounded, playful display face) for headings and buttons,
/// **Nunito** (rounded, highly legible) for body copy. Both are SIL OFL licensed.
///
/// Names are the fonts' PostScript names. All tokens scale with Dynamic Type via `relativeTo:`.
enum AppFont {
    enum Fredoka: String {
        case medium = "FredokaLight-Medium"
        case semiBold = "FredokaLight-SemiBold"
        case bold = "FredokaLight-Bold"
    }

    enum Nunito: String {
        case regular = "NunitoExtraLight-Regular"
        case semiBold = "NunitoExtraLight-SemiBold"
        case bold = "NunitoExtraLight-Bold"
        case extraBold = "NunitoExtraLight-ExtraBold"
    }

    static func display(_ weight: Fredoka, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        .custom(weight.rawValue, size: size, relativeTo: style)
    }

    static func body(_ weight: Nunito, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        .custom(weight.rawValue, size: size, relativeTo: style)
    }
}

extension Font {
    static let displayHero = AppFont.display(.bold, size: 48, relativeTo: .largeTitle)
    static let displayLarge = AppFont.display(.bold, size: 34, relativeTo: .largeTitle)
    static let displayMedium = AppFont.display(.semiBold, size: 26, relativeTo: .title)
    static let displaySmall = AppFont.display(.semiBold, size: 20, relativeTo: .title3)

    static let buttonLabel = AppFont.display(.semiBold, size: 19, relativeTo: .headline)
    static let badgeLabel = AppFont.display(.bold, size: 14, relativeTo: .caption)

    static let bodyLarge = AppFont.body(.semiBold, size: 17, relativeTo: .body)
    static let bodyMedium = AppFont.body(.regular, size: 15, relativeTo: .subheadline)
    static let label = AppFont.body(.extraBold, size: 13, relativeTo: .caption)
}
