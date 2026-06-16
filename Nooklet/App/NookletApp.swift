import SwiftUI

@main
struct NookletApp: App {
    @State private var router = AppRouter()
    @State private var activeTab: AppTab = .home
    @State private var isExpanded: Bool = false

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundStyle(.clear)
                    .overlay {
                        switch activeTab {
                        case .home:
                            HomeScreen()

                        case .search:
                           RecordingScreen()

                        default:
                            HomeScreen()
                        }
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
