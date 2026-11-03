import SwiftUI

/// Screen recorder tab. Placeholder until its UI is specified.
struct RecorderView: View {
    var body: some View {
        PlaceholderScreen(icon: "record.circle.fill",
                          title: "Screen Recorder",
                          message: "Start a new recording from here.",
                          tint: HomeTab.recorder.accent,
                          titleIdentifier: "recorder.title")
    }
}

#Preview {
    RecorderView().background(AppBackground(glow: Palette.record))
}
