import SwiftUI

public struct CinematicBackground: View {
    @State private var animateBackground = false

    public init() {}

    public var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.05)  // Deep premium dark background

            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(animateBackground ? 0.2 : 0.1))
                        .frame(width: geo.size.width * 1.2)
                        .blur(radius: 120)
                        .offset(
                            x: animateBackground
                                ? -geo.size.width * 0.2 : -geo.size.width * 0.4,
                            y: animateBackground
                                ? -geo.size.height * 0.1
                                : -geo.size.height * 0.2
                        )

                    Circle()
                        .fill(
                            Color.purple.opacity(
                                animateBackground ? 0.15 : 0.05
                            )
                        )
                        .frame(width: geo.size.width)
                        .blur(radius: 100)
                        .offset(
                            x: animateBackground
                                ? geo.size.width * 0.3 : geo.size.width * 0.5,
                            y: animateBackground
                                ? geo.size.height * 0.3 : geo.size.height * 0.4
                        )
                }
            }
            .drawingGroup()
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8.0).repeatForever(autoreverses: true)
            ) {
                animateBackground = true
            }
        }
    }
}
