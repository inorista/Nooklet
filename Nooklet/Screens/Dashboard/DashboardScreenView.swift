//
//  DashboardScreenView.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI

struct DashboardScreenView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var activeTab: AppTab = .home

    var body: some View {
        NavigationStack(path: $coordinator.dashboardPath) {
            TabView(selection: $activeTab) {
                HomeScreenView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                    .tabItem {
                        Image(
                            AppTab.home.imageName(isActive: activeTab == .home)
                        )
                    }
                    .tag(AppTab.home)

                SpeechScreenView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                    .tabItem {
                        Image(
                            AppTab.speech.imageName(isActive: activeTab == .speech)
                        )
                    }
                    .tag(AppTab.speech)

                Text("Settings Screen")
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                    .tabItem {
                        Image(
                            AppTab.setting.imageName(
                                isActive: activeTab == .setting
                            )
                        )
                    }
                    .tag(AppTab.setting)
            }
            .tint(Color(.content))
            .navigationDestination(for: DashboardRoute.self) { route in
                switch route {
                case .speech:
                    SpeechScreenView()
                case .settings:
                    Text("Settings Screen")
                case .chat(let sessionId):
                    ChatScreenView(sessionId: sessionId)
                case .chatHistory:
                    ChatHistoryScreenView()
                }

            }
        }
    }
}
