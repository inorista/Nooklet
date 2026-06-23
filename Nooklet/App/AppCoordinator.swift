import SwiftUI


enum AppFlow: Equatable {
    case splash
    case onboarding
    case register
    case dashboard
}


enum DashboardRoute: Hashable {
    case recording
    case settings
    case chat(sessionId: UUID?)
    case chatHistory
}

@MainActor
final class AppCoordinator: ObservableObject {

    @Published private(set) var currentFlow: AppFlow = .splash

    @Published var dashboardPath = NavigationPath()


    private let userDefaults: UserDefaultsService


    init(userDefaults: UserDefaultsService = .shared) {
        self.userDefaults = userDefaults
    }


    func onSplashFinished() {
        let nextFlow: AppFlow = userDefaults.hasSeenOnboarding ? .dashboard : .onboarding
        withAnimation(.easeInOut(duration: 0.5)) {
            currentFlow = nextFlow
        }
    }

    func onOnboardingCompleted() {
        withAnimation(.easeInOut(duration: 0.4)) {
            currentFlow = .register
        }
    }

    func onRegistrationCompleted() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentFlow = .dashboard
        }
    }

    func push(_ route: DashboardRoute) {
        dashboardPath.append(route)
    }

    func pop() {
        guard !dashboardPath.isEmpty else { return }
        dashboardPath.removeLast()
    }

    func popToRoot() {
        dashboardPath = NavigationPath()
    }
}
