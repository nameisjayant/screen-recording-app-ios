import SwiftUI

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let state = viewModel.state
        let accent = state.currentPage.kind.accent

        ZStack {
            AppBackground(glow: accent)

            VStack(spacing: Spacing.m) {
                OnboardingTopBar(
                    currentIndex: state.currentIndex,
                    pageCount: state.pages.count,
                    accent: accent,
                    showsSkip: !state.isLastPage,
                    onSkip: { viewModel.send(.skip) }
                )
                .padding(.top, Spacing.xs)

                TabView(selection: pageSelection) {
                    ForEach(Array(state.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Button {
                    withAnimation(.smooth) { viewModel.send(.next) }
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Text(state.isLastPage ? "Get Started" : "Next")
                        Image(systemName: state.isLastPage ? "checkmark" : "arrow.right")
                            .font(.system(size: 16, weight: .heavy))
                    }
                    .contentTransition(.interpolate)
                }
                .buttonStyle(.game(state.isLastPage ? .record : .primary))
                .accessibilityIdentifier("onboarding.primary")
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.s)
                .animation(.smooth, value: state.isLastPage)
            }
        }
        .sensoryFeedback(.selection, trigger: state.currentIndex)
    }

    private var pageSelection: Binding<Int> {
        Binding(
            get: { viewModel.state.currentIndex },
            set: { viewModel.send(.selectPage($0)) }
        )
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(onFinish: {}))
}
