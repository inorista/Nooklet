import SwiftUI

@main
struct NookletApp: App {
    @State private var router = AppRouter()
    @State private var activeTab: AppTab = .home
    @State private var isExpanded: Bool = false
    @State private var isKeyboardVisible: Bool = false

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundStyle(.clear)
                    .overlay {
                        ZStack {
                            ChatScreen()
                                .scaleEffect(activeTab == .search ? 0.95 : 1.0)
                                .opacity(activeTab == .search ? 0 : 1)
                                .allowsHitTesting(activeTab != .search)

                            RecordingScreen()
                                .scaleEffect(activeTab == .search ? 1.0 : 0.95)
                                .opacity(activeTab == .search ? 1 : 0)
                                .allowsHitTesting(activeTab == .search)
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: activeTab)
                    }
                MorphingTabBar(activeTab: $activeTab, isExpanded: $isExpanded) {
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}
