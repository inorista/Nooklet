//
//  HomeScreenView.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI


struct HomeScreenView: View {
    @Environment(AppRouter.self) private var router
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("RadientPrimary"), Color("RadientSecondary"),
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(viewModel.greeting)
                        .font(
                            .system(size: 28, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("Content"), Color("Info")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: Color("Info").opacity(0.25),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                        .padding(.top, 12)

                    CustomButton(
                        buttonColor: Color("Button"),
                        title: "New Chat",
                        shadowColor: Color("Button"),
                        action: {
                            router.push(.recording)
                        }
                    )
                    .padding(.horizontal, 12)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.top)
        }
    }
}

#Preview {
    HomeScreenView()
}
