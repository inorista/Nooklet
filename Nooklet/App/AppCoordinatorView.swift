//
//  AppCoordinatorView.swift
//  Nooklet
//
//  Created by Tu on 20/6/26.
//

import SwiftUI

/// The root view that renders the correct screen based on the coordinator's current flow.
/// This is the only place that switches on `AppFlow`.
struct AppCoordinatorView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            switch coordinator.currentFlow {
            case .splash:
                SplashScreenView()
                    .transition(.opacity)

            case .onboarding:
                OnboardingScreenView(viewModel: OnboardingViewModel())
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .register:
                RegisterUserView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .dashboard:
                DashboardScreenView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: coordinator.currentFlow)
    }
}
