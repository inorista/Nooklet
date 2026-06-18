import SwiftUI

enum Route: Hashable {
    case recording
    case settings
}

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
