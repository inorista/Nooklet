//
//  HomeScreenView.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//
import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
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
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(viewModel.greeting)
                                .font(
                                    .system(
                                        size: 28,
                                        weight: .heavy,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color("Content"), Color("Info"),
                                        ],
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

                            Spacer()

                            if viewModel.user != nil {
                                Text(
                                    "\(viewModel.user!.firstName) \(viewModel.user!.lastName)"
                                )
                                .font(
                                    .system(
                                        size: 22,
                                        weight: .heavy,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(
                                    Color(.subContent)
                                )
                            }
                        }
                        Spacer()

                        if viewModel.user != nil {
                            Image(viewModel.user!.imageData!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color(.border), lineWidth: 2)
                                )
                        }
                    }
                    .padding(.bottom, 12)

                    CustomButton(
                        buttonColor: Color("Button"),
                        title: "New Chat",
                        shadowColor: Color("Button"),
                        action: {
                            coordinator.push(.chat)
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .safeAreaPadding(.top)
            .padding(.horizontal, 20)
        }
        .onAppear {
            Task {
                await viewModel.loadUserData()
            }

        }
    }
}

#Preview {
    HomeScreenView()
}
