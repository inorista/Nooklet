//
//  SplashScreenView.swift
//  Nooklet
//
//  Created by Tu on 20/6/26.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.radientPrimary), Color(.radientSecondary),
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            Image(.nooklet)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3  ) {
                coordinator.onSplashFinished()
            }
        }
    }
}
