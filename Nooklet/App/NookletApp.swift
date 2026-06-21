import RealmSwift
import SwiftUI

@main
struct NookletApp: SwiftUI.App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(coordinator)
        }
    }
}
