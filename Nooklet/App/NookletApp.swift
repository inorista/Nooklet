import SwiftData
import SwiftUI

@main
struct NookletApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                AppContentView()
            } else {
                OnboardingScreenView()
            }
        }
        .modelContainer(for: [ChatSession.self, ChatMessage.self])
    }
}
