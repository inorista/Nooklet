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
    @State private var isExpanded: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.dashboardPath) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundStyle(.clear)
                    .ignoresSafeArea()
                    .overlay {
                        ZStack {
                            HomeScreenView()
                                .opacity(activeTab == .home ? 1 : 0)
                                .allowsHitTesting(activeTab == .home)
                            Text("OK")
                                .opacity(activeTab == .chat ? 1 : 0)
                                .allowsHitTesting(activeTab == .chat)
                            Text("OK")
                                .opacity(activeTab == .setting ? 1 : 0)
                                .allowsHitTesting(activeTab == .setting)
                            //                            ChatScreen()
                            //                                .opacity(activeTab == .chat ? 1 : 0)
                            //                                .allowsHitTesting(activeTab == .chat)
                            //
                            //                            RecordingScreen()
                            //                                .opacity(activeTab == .setting ? 1 : 0)
                            //                                .allowsHitTesting(activeTab == .setting)
                        }
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.85),
                            value: activeTab
                        )
                    }
                MorphingTabBar(activeTab: $activeTab, isExpanded: $isExpanded) {
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
            .navigationDestination(for: DashboardRoute.self) { route in
                switch route {
                case .recording:
                    RecordingScreen()
                case .settings:
                    Text("Settings Screen")
                case .chat:
                    ChatScreenView()
                }

            }
        }
    }
}
