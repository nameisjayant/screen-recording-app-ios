import ReplayKit
import UIKit

/// Opens the iOS "Screen Broadcast" sheet with RecQuest's extension preselected.
///
/// Only the system sheet may start a broadcast, so we tap its button for the user; they still confirm with
/// "Start Broadcast", which is also where iOS shows its microphone switch.
final class BroadcastPickerLauncher {
    private let extensionBundleIdentifier = Bundle.main.object(forInfoDictionaryKey: "BroadcastExtensionBundleIdentifier") as? String
    private var picker: RPSystemBroadcastPickerView?

    func present(showsMicrophoneButton: Bool) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) else { return }

        let picker = picker ?? RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        picker.preferredExtension = extensionBundleIdentifier
        picker.showsMicrophoneButton = showsMicrophoneButton
        picker.alpha = 0.011
        picker.isUserInteractionEnabled = false
        if picker.window !== window { window.addSubview(picker) }
        self.picker = picker

        for case let button as UIButton in picker.subviews {
            button.sendActions(for: .allTouchEvents)
        }
    }
}
