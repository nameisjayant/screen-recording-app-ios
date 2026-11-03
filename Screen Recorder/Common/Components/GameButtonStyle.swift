import SwiftUI

/// Color treatments for `GameButtonStyle`.
enum GameButtonTint {
    case primary
    case record
    case sun
    case mint

    var face: Color {
        switch self {
        case .primary: Palette.primary
        case .record: Palette.record
        case .sun: Palette.sun
        case .mint: Palette.mint
        }
    }

    var edge: Color {
        switch self {
        case .primary: Palette.primaryEdge
        case .record: Palette.recordEdge
        case .sun: Palette.sunEdge
        case .mint: Palette.mintEdge
        }
    }

    var foreground: Color {
        switch self {
        case .primary, .record: .white
        case .sun, .mint: Palette.ink
        }
    }
}

/// Chunky arcade button: a bright face sitting on a darker 3D edge that sinks when pressed.
struct GameButtonStyle: ButtonStyle {
    var tint: GameButtonTint = .primary
    var fillsWidth = true

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
        let pressed = configuration.isPressed

        configuration.label
            .font(.buttonLabel)
            .foregroundStyle(tint.foreground)
            .padding(.horizontal, Spacing.l)
            .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: 56)
            .background {
                shape.fill(tint.face)
                    .overlay(alignment: .top) {
                        // Glossy highlight strip for that toy-like finish.
                        Capsule()
                            .fill(.white.opacity(0.22))
                            .frame(height: 6)
                            .padding(.horizontal, Spacing.m)
                            .padding(.top, Spacing.xs)
                    }
            }
            .offset(y: pressed ? Motion.pressDepth : 0)
            .background { shape.fill(tint.edge).offset(y: Motion.pressDepth) }
            .padding(.bottom, Motion.pressDepth)
            .saturation(isEnabled ? 1 : 0)
            .opacity(isEnabled ? 1 : 0.6)
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: pressed)
    }
}

extension ButtonStyle where Self == GameButtonStyle {
    static func game(_ tint: GameButtonTint = .primary, fillsWidth: Bool = true) -> GameButtonStyle {
        GameButtonStyle(tint: tint, fillsWidth: fillsWidth)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        Button("Get Started") {}.buttonStyle(.game())
        Button("Record") {}.buttonStyle(.game(.record))
        Button("Share") {}.buttonStyle(.game(.sun))
        Button("Disabled") {}.buttonStyle(.game(.mint)).disabled(true)
    }
    .padding()
    .background(Palette.background)
}
