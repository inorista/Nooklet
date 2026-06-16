import SwiftUI

/// Root container that owns the `NavigationStack` and routes to screens.
struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            RecordingScreen()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .recording:
                        RecordingScreen()
                    case .settings:
                        Text("Settings (coming soon)")
                    }
                }
        }
    }
}

#Preview {
    RootView()
        .environment(AppRouter())
}
