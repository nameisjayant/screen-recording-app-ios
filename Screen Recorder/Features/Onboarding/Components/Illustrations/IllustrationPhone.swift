import SwiftUI

/// Chunky toy-like phone used to stage onboarding illustrations.
struct IllustrationPhone<Screen: View>: View {
    var width: CGFloat = 160
    @ViewBuilder var screen: Screen

    var body: some View {
        let height = width * 2
        let outer = RoundedRectangle(cornerRadius: width * 0.2, style: .continuous)
        let inner = RoundedRectangle(cornerRadius: width * 0.15, style: .continuous)

        ZStack {
            outer.fill(Palette.backgroundDeep).offset(y: 10)
            outer.fill(Palette.surfaceRaised)
            outer.stroke(Palette.outline, lineWidth: 3)
            screen
                .frame(width: width - 18, height: height - 18)
                .clipShape(inner)
            Capsule()
                .fill(Palette.backgroundDeep)
                .frame(width: width * 0.3, height: 12)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 16)
        }
        .frame(width: width, height: height)
        .accessibilityHidden(true)
    }
}

/// Rounded speech bubble with a tail, used in illustrations.
struct SpeechBubble: View {
    let text: LocalizedStringKey
    var color: Color
    var tailOnLeading = true

    var body: some View {
        Text(text)
            .font(.displaySmall)
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.xs)
            .background(RoundedRectangle(cornerRadius: Radius.s, style: .continuous).fill(color))
            .overlay(alignment: tailOnLeading ? .bottomLeading : .bottomTrailing) {
                Triangle()
                    .fill(color)
                    .frame(width: 16, height: 12)
                    .offset(x: tailOnLeading ? 14 : -14, y: 10)
            }
            .accessibilityHidden(true)
    }
}

private struct Triangle: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
