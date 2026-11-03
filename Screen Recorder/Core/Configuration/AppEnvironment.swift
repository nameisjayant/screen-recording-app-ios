import Foundation

/// The build flavor, resolved at compile time from the `BETA` / `PROD` conditions set in `Config/*.xcconfig`.
enum AppEnvironment: String {
    case beta
    case prod

    static let current: AppEnvironment = {
        #if BETA
        .beta
        #else
        .prod
        #endif
    }()

    var isBeta: Bool { self == .beta }

    /// True when launched by the UI test runner, which passes `LaunchArgument.uiTesting`.
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(LaunchArgument.uiTesting)
    }
}

enum LaunchArgument {
    static let uiTesting = "--ui-testing"
}
