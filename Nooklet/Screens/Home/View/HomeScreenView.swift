//
//  HomeScreenView.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var viewModel = HomeViewModel()
    @State private var isNewChatPressed = false
    @State private var animateAvatarPulse = false
    @State private var animateDotPulse = false

    var body: some View {
        ZStack {
            CinematicBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack(spacing: 36) {
                        GreetingUser()
                        BentoGridSection()
                        ChatHistory()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 48)
                    .frame(maxWidth: 800)
                }
                .frame(maxWidth: .infinity)
            }
            .applyScrollEdgeEffectStyle()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.initData()
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(
                .easeOut(duration: 2.0).repeatForever(autoreverses: false)
            ) {
                animateAvatarPulse = true
            }
            withAnimation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
            ) {
                animateDotPulse = true
            }
        }
    }

    // MARK: - Greeting User
    @ViewBuilder
    func GreetingUser() -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(3.0)
                    .foregroundStyle(.white.opacity(0.5))

                HStack(alignment: .center, spacing: 12) {
                    if let user = viewModel.user {
                        Text(user.firstName)
                            .font(
                                .system(
                                    size: 48,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Text("Nooklet")
                            .font(
                                .system(
                                    size: 48,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                    }
                }
            }

            Spacer()

            if let user = viewModel.user, let imgName = user.imageData {
                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Bento Grid Section
    @ViewBuilder
    func BentoGridSection() -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Card: New Conversation
            NewChatBentoCard()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Right Cards
            VStack(spacing: 16) {
                ModelStatusBentoCard()
                VoiceCapabilitiesBentoCard()
            }
            .frame(width: horizontalSizeClass == .regular ? 240 : 150)
        }
        .frame(height: horizontalSizeClass == .regular ? 280 : 240)
    }

    // MARK: - New Chat Bento Card
    @ViewBuilder
    func NewChatBentoCard() -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            coordinator.push(.chat(sessionId: nil))
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.black.opacity(0.4))
                    .background(.ultraThinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                    )

                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3), .white.opacity(0.05),
                                .clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )

                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 56, height: 56)

                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, 24)

                    Spacer()

                    Text("New Chat")
                        .font(
                            .system(size: 28, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .padding(.bottom, 4)

                    Text("Start a private, on-device AI session.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(24)
            }
        }
        .buttonStyle(BouncyCardStyle())
    }

    // MARK: - Model Status Bento Card
    @ViewBuilder
    func ModelStatusBentoCard() -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.3))
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16)

                Text("Local LLM")
                    .font(
                        .system(size: 12, weight: .semibold, design: .rounded)
                    )
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 2)

                Text("Gemma 4 (2B)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(16)
        }
        .frame(height: 112)
    }

    // MARK: - Voice Capabilities Bento Card
    @ViewBuilder
    func VoiceCapabilitiesBentoCard() -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.3))
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "waveform")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 16)

                Text("Text-to-Speech")
                    .font(
                        .system(size: 12, weight: .semibold, design: .rounded)
                    )
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 2)

                Text("Supertonic")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(16)
        }
        .frame(height: 112)
    }

    // MARK: - Chat History
    @ViewBuilder
    func ChatHistory() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Sessions")
                        .font(
                            .system(size: 24, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.white)
                    Text("Your private chats saved locally")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Button {
                    coordinator.push(.chatHistory)
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1), in: Circle())
                        .overlay(
                            Circle().stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(BouncyCardStyle())
            }

            if viewModel.chatSessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.3))

                    Text("No saved conversations")
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)

                    Text(
                        "All chats are automatically encrypted and persisted on your device."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
                .background(Color.black.opacity(0.2))
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(.white.opacity(0.05), lineWidth: 1)
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(viewModel.chatSessions) { item in
                            ChatHistoryCard(item: item)
                        }
                    }
                    .padding(.vertical, 8)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .applyScrollEdgeEffectStyle()
            }
        }
    }

    @ViewBuilder
    func ChatHistoryCard(item: HomeChatSession) -> some View {
        Button {
            coordinator.push(.chat(sessionId: item.id))
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(
                            .system(size: 18, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(item.firstAnswer ?? "Empty conversation")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(width: 240, height: 180, alignment: .topLeading)
            .background(Color.black.opacity(0.3))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(BouncyCardStyle())
        .scrollTransition(axis: .horizontal) { content, phase in
            content
                .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                .opacity(phase.isIdentity ? 1.0 : 0.4)
                .rotation3DEffect(
                    .degrees(phase.value * -15),
                    axis: (x: 0.0, y: 1.0, z: 0.0),
                    perspective: 0.8
                )
                .offset(y: phase.isIdentity ? 0 : 20)
        }
    }
}

#Preview {
    HomeScreenView()
}
