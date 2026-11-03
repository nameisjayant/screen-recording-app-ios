import Foundation

/// Small key-value settings the app persists between launches.
protocol AppPreferences: AnyObject {
    var hasCompletedOnboarding: Bool { get set }
    /// Last face cam / microphone choices from the recording setup dialog.
    var recordingOptions: RecordingOptions { get set }
    var theme: AppTheme { get set }
}

final class UserDefaultsAppPreferences: AppPreferences {
    private enum Key {
        static let hasCompletedOnboarding = "preferences.hasCompletedOnboarding"
        static let isFaceCamEnabled = "preferences.recording.isFaceCamEnabled"
        static let isMicrophoneEnabled = "preferences.recording.isMicrophoneEnabled"
        static let theme = "preferences.theme"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }

    var recordingOptions: RecordingOptions {
        get {
            let defaults = RecordingOptions()
            return RecordingOptions(
                isFaceCamEnabled: self.defaults.object(forKey: Key.isFaceCamEnabled) as? Bool ?? defaults.isFaceCamEnabled,
                isMicrophoneEnabled: self.defaults.object(forKey: Key.isMicrophoneEnabled) as? Bool ?? defaults.isMicrophoneEnabled
            )
        }
        set {
            defaults.set(newValue.isFaceCamEnabled, forKey: Key.isFaceCamEnabled)
            defaults.set(newValue.isMicrophoneEnabled, forKey: Key.isMicrophoneEnabled)
        }
    }

    var theme: AppTheme {
        get { defaults.string(forKey: Key.theme).flatMap(AppTheme.init(rawValue:)) ?? .default }
        set { defaults.set(newValue.rawValue, forKey: Key.theme) }
    }
}

/// Non-persistent store for previews, unit tests and UI tests.
final class InMemoryAppPreferences: AppPreferences {
    var hasCompletedOnboarding: Bool
    var recordingOptions: RecordingOptions
    var theme: AppTheme

    init(hasCompletedOnboarding: Bool = false,
         recordingOptions: RecordingOptions = RecordingOptions(),
         theme: AppTheme = .default) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.recordingOptions = recordingOptions
        self.theme = theme
    }
}
