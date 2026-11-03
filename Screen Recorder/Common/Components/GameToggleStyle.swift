import SwiftUI

/// Chunky switch: a 3D track that fills with `tint` when on, with a glossy knob that slides across.
struct GameToggleStyle: ToggleStyle {
    var tint: Color = Palette.mint

    func makeBody(configuration: Configuration) -> some View {
        let isOn = configuration.isOn
        let width: CGFloat = 58
        let height: CGFloat = 34
        let knob: CGFloat = 26

        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: Spacing.m) {
                configuration.label
                Spacer(minLength: 0)
                ZStack(alignment: isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(isOn ? tint : Palette.backgroundDeep)
                        .overlay(Capsule().stroke(isOn ? tint : Palette.outline, lineWidth: 2))
                    Circle()
                        .fill(.white)
                        .overlay(alignment: .top) {
                            Capsule()
                                .fill(Palette.ink.opacity(0.08))
                                .frame(width: knob * 0.5, height: 3)
                                .offset(y: knob - 7)
                        }
                        .frame(width: knob, height: knob)
                        .shadow(color: .black.opacity(0.25), radius: 0, y: 2)
                        .padding(4)
                }
                .frame(width: width, height: height)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isOn)
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
    }
}

extension ToggleStyle where Self == GameToggleStyle {
    static func game(_ tint: Color = Palette.mint) -> GameToggleStyle {
        GameToggleStyle(tint: tint)
    }
}

#Preview {
    @Previewable @State var isOn = true
    VStack(spacing: Spacing.m) {
        Toggle("Microphone", isOn: $isOn).toggleStyle(.game())
        Toggle("Face Camera", isOn: .constant(false)).toggleStyle(.game(Palette.sun))
    }
    .foregroundStyle(.white)
    .padding()
    .background(Palette.background)
}
