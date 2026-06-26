import RealmSwift
import SwiftUI

@main
struct NookletApp: SwiftUI.App {
    @StateObject private var coordinator = AppCoordinator()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(coordinator)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Force portrait on iPhone to maintain UI design,
        // but allow all orientations on iPad (or to satisfy Apple's validator).
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        }
        return .all
    }
}
