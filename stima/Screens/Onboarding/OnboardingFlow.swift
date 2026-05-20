import SwiftUI

/// Onboarding 流程容器：Splash → Intro → TutorialCTA。
/// 完成後設 `settings.hasSeenOnboarding = true`，RootView 會自動切到 ContentView。
struct OnboardingFlow: View {
    @Environment(AppSettings.self) private var settings
    @State private var path: [Step] = []

    enum Step: Hashable {
        case intro
        case tutorialCTA
    }

    var body: some View {
        NavigationStack(path: $path) {
            SplashScreen {
                path.append(.intro)
            }
            .navigationDestination(for: Step.self) { step in
                switch step {
                case .intro:
                    IntroScreen {
                        path.append(.tutorialCTA)
                    }
                case .tutorialCTA:
                    TutorialCTAScreen(
                        onStart: { finish() },
                        onSkip:  { finish() }
                    )
                }
            }
        }
    }

    private func finish() {
        settings.hasSeenOnboarding = true
    }
}

#Preview {
    OnboardingFlow()
        .environment(AppSettings())
}
