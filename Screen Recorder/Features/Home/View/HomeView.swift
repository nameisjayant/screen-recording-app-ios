import SwiftUI

/// Home shell. The full home UI is coming next; add a `HomeViewModel` once the screen has state.
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: Spacing.l) {
                    Spacer()
                    AppLogoMark(size: 110)
                    Text("Ready to record")
                        .font(.displayMedium)
                        .foregroundStyle(Palette.textPrimary)
                        .accessibilityIdentifier("home.title")
                    Text("The home screen is under construction.")
                        .font(.bodyMedium)
                        .foregroundStyle(Palette.textSecondary)
                    Spacer()
                }
                .padding(Spacing.l)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    HomeView()
}
