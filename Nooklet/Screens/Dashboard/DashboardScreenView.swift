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

                ExploreScreenView()
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                    .tabItem {
                        Image(
                            AppTab.explore.imageName(
                                isActive: activeTab == .explore
                            )
                        )
                    }
                    .tag(AppTab.explore)

                SettingScreenView()
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
                    SettingScreenView()
                case .chat(let sessionId):
                    ChatScreenView(sessionId: sessionId)
                case .chatHistory:
                    ChatHistoryScreenView()
                }

            }
            .navigationViewStyle(.stack)
        }
    }
}
