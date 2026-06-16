import SwiftUI

/// All navigable destinations in the app.
enum Route: Hashable {
    case recording
    case settings
}

/// Centralised navigation state — injected into the environment.
@MainActor
@Observable
final class AppRouter {
    var path = NavigationPath()

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
