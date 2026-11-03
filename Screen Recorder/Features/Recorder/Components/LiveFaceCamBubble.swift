import AVFoundation
import SwiftUI

/// Draggable round bubble showing the front camera while recording. It's part of the screen, so the
/// recording captures it; outside RecQuest the feed continues in Picture in Picture.
struct LiveFaceCamBubble: View {
    let layer: AVSampleBufferDisplayLayer
    var size: CGFloat = 120

    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        FaceCamLayerView(layer: layer)
            .frame(width: size, height: size)
            .background(Palette.surfaceRaised)
            .clipShape(Circle())
            .overlay(Circle().stroke(Palette.mint, lineWidth: 4))
            .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
            .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                    }
            )
            .accessibilityLabel(Text("Face camera"))
            .accessibilityIdentifier("recording.faceCam")
    }
}

/// Hosts the camera's display layer, which Picture in Picture also needs to be on screen.
private struct FaceCamLayerView: UIViewRepresentable {
    let layer: AVSampleBufferDisplayLayer

    func makeUIView(context: Context) -> LayerHostView {
        LayerHostView(hosted: layer)
    }

    func updateUIView(_ uiView: LayerHostView, context: Context) {}

    final class LayerHostView: UIView {
        private let hosted: CALayer

        init(hosted: CALayer) {
            self.hosted = hosted
            super.init(frame: .zero)
            layer.addSublayer(hosted)
        }

        required init?(coder: NSCoder) { nil }

        override func layoutSubviews() {
            super.layoutSubviews()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            hosted.frame = bounds
            CATransaction.commit()
        }
    }
}
