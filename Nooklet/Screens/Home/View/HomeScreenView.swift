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
            RadientBackground()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    GreetingUser()
                    CustomButton(
                        buttonColor: Color(.subContent),
                        title: "New Chat",
                        shadowColor: Color(.subContent),
                        action: {
                            coordinator.push(.chat(sessionId: nil))
                        }
                    )
                    ChatHistory()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .safeAreaPadding(.top)
            .padding(.horizontal, 20)
            .applyScrollEdgeEffectStyle()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.initData()
        }
    }

    @ViewBuilder
    func ChatHistory() -> some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                Text("Chat history")
                    .font(
                        .system(
                            size: 24,
                            weight: .heavy,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color(.subContent)
                    )
                Spacer()
                Button {

                } label: {
                    Image(
                        systemName: "arrow.forward"
                    )
                    .font(
                        .caption
                    )
                    .fontWeight(.bold)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(
                        Color(.border)
                    )
                    .background(
                        Color(.subContent),
                        in: .circle
                    )
                    .padding(4)
                    .contentTransition(.symbolEffect(.replace))
                }
            }

            if viewModel.chatSessions.isEmpty {
                Text("No chat session found")
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 16) {
                        ForEach(
                            viewModel.chatSessions.indices,
                            id: \.self
                        ) {
                            index in

                            let currentItem =
                                viewModel.chatSessions[
                                    index
                                ]

                            VStack(alignment: .leading, spacing: 12) {
                                Text(currentItem.title)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(
                                        Color(.content)
                                    )
                                    .lineLimit(1)

                                Text(currentItem.firstAnswer ?? "")
                                    .font(.caption)
                                    .foregroundStyle(
                                        Color(.subContent)
                                    )
                                    .lineLimit(5)
                            }
                            .frame(width: 220)
                            .padding(16)
                            .background(
                                Color(.historyCard)
                            )
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .applyScrollEdgeEffectStyle()
            }
        }
        .padding(.top, 10)
    }

    @ViewBuilder
    func GreetingUser() -> some View {
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
    }

    @ViewBuilder
    func RadientBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color("RadientPrimary"), Color("RadientSecondary"),
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

#Preview {
    HomeScreenView()
}
