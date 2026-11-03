import SwiftUI

struct SplashView: View {
    @State private var viewModel: SplashViewModel

    init(viewModel: SplashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let phase = viewModel.state.phase

        ZStack {
            AppBackground(glow: Palette.record)

            VStack(spacing: Spacing.m) {
                Spacer()

                ZStack {
                    SplashSparkleField(isVisible: phase >= .logo)
                    SplashLogo(isVisible: phase >= .logo)
                }

                SplashTitle(text: "RecQuest", isVisible: phase >= .title)

                Text("Record. Narrate. Share.")
                    .font(.bodyLarge)
                    .foregroundStyle(Palette.textSecondary)
                    .opacity(phase >= .title ? 1 : 0)
                    .offset(y: phase >= .title ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: phase)

                Spacer()

                SplashLoader(isLoading: phase >= .loading)
                    .padding(.horizontal, Spacing.xxl)

                if viewModel.state.showsBetaBadge {
                    TagPill(text: "Beta build", color: Palette.sun)
                }
            }
            .padding(.bottom, Spacing.xl)
        }
        .contentShape(Rectangle())
        .onTapGesture { viewModel.send(.skipRequested) }
        .task { await viewModel.start() }
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel(environment: .beta, onFinish: {}))
}
