import SwiftUI

/// Dashboard tab. Placeholder until its UI is specified; add a `DashboardViewModel` once it has state.
struct DashboardView: View {
    var body: some View {
        PlaceholderScreen(icon: HomeTab.dashboard.icon,
                          title: "Dashboard",
                          message: "Your recordings will show up here.",
                          tint: HomeTab.dashboard.accent,
                          titleIdentifier: "home.title")
    }
}

#Preview {
    DashboardView().background(AppBackground())
}
