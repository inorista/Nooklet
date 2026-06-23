//
//  ChatScreenView.swift
//  Nooklet
//
//  Created by Tu on 21/6/26.
//

import SwiftUI

struct ChatScreenView: View {
    var sessionId: UUID?

    @StateObject private var viewModel: ChatViewModel = ChatViewModel()
    @Namespace private var bottomAnchor

    var body: some View {
        ZStack(alignment: .bottom) {
            RadientBackground()
            ChatBodyContent()
            TextFieldChat()
        }
        .onTapGesture {
            KeyboardUtils.closeKeyboard()
        }
        .navigationTitle(viewModel.currentSession?.title ?? "New Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadInitialData(sessionId: sessionId)
        }
    }

    // MARK: - Chat Body Content

    @ViewBuilder
    func ChatBodyContent() -> some View {
        if viewModel.isModelLoading {
            // Loading state
            VStack(spacing: 14) {
                ProgressView()
                    .tint(Color(.info))
                    .scaleEffect(1.2)
                Text(
                    "The Gemma 4 model is initializing. Please wait a moment..."
                )
                .font(.caption)
                .foregroundStyle(Color(.content))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        } else if viewModel.messages.isEmpty {
            // Welcome / empty state
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(.info), Color(.primary)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse, options: .repeating)
                Text("How can I help you today?")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.content))
                Text("Ask me anything — I'm powered by on-device AI.")
                    .font(.subheadline)
                    .foregroundStyle(Color(.subContent))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 100)
        } else {
            // Message list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(
                            Array(viewModel.messages.enumerated()),
                            id: \.element.id
                        ) { index, message in
                            ChatBubbleView(
                                message: message,
                                isThinking: viewModel.isThinking,
                                isLastAIMessage: isLastAIMessage(
                                    at: index
                                )
                            )
                            .id(message.id)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(
                                        with: .move(edge: .bottom)
                                    ),
                                    removal: .opacity
                                )
                            )
                        }

                        Color.clear
                            .frame(height: 180)
                            .id("bottom_anchor")
                    }
                    .padding(.top, 12)
                }
                .applyScrollEdgeEffectStyle()
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(
                            "bottom_anchor",
                            anchor: .bottom
                        )
                    }
                }
                .onChange(of: viewModel.messages.last?.content) {
                    _,
                    _ in
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo(
                            "bottom_anchor",
                            anchor: .bottom
                        )
                    }
                }
            }
        }
    }

    /// Check if the message at given index is the last AI message
    private func isLastAIMessage(at index: Int) -> Bool {
        guard !viewModel.messages[index].isUserMessage else { return false }
        // Check if there are no AI messages after this index
        let remaining = viewModel.messages[(index + 1)...]
        return !remaining.contains(where: { !$0.isUserMessage })
    }

    // MARK: - Background

    @ViewBuilder
    func RadientBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.radientPrimary), Color(.radientSecondary),
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }

    // MARK: - Text Field Chat

    @ViewBuilder
    func TextFieldChat() -> some View {
        ZStack(alignment: .bottom) {
            if #available(iOS 26.0, *) {
                LinearGradient(
                    colors: [
                        Color(.radientSecondary).opacity(0),
                        Color(.radientSecondary).opacity(0.85),
                        Color(.radientSecondary),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 150)
                .glassEffect()
                .blur(radius: 20)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            } else {
                LinearGradient(
                    colors: [
                        Color(.radientSecondary).opacity(0),
                        Color(.radientSecondary).opacity(0.85),
                        Color(.radientSecondary),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 150)
                .blur(radius: 20)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }

            LazyVStack {
                if let selectedImage = viewModel.selectedUIImage {
                    HStack {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Button {
                                viewModel.clearSelectedImage()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color(.danger))
                                    .background(Color(.surface), in: .circle)
                            }
                            .offset(x: 6, y: -6)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .transition(.scale.combined(with: .opacity))
                }

                LazyVStack(alignment: .leading, spacing: 25) {
                    TextField(
                        "",
                        text: $viewModel.inputText,
                        prompt: Text("Ask Anything....")
                            .foregroundColor(Color(.content).opacity(0.7))
                            .font(.callout),
                        axis: .vertical
                    )
                    .lineLimit(1...8)
                    .disabled(viewModel.isModelLoading)
                    .padding(.top, 8)
                    .foregroundStyle(Color(.content))

                    HStack(alignment: .center, spacing: 20) {
                        Button {
                            print("OK")
                        } label: {
                            Text(
                                "Model: \(viewModel.selectedModelIdentifier.displayName)"
                            )
                            .font(.caption)
                            .foregroundStyle(Color.primary.opacity(0.8))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(
                                Color(.imagePlaceHolder),
                                in: .capsule
                            )
                        }
                        Spacer(minLength: 0)
                        Group {
                            Button {

                            } label: {
                                Image(systemName: "photo.fill")
                                    .foregroundStyle(
                                        Color(.subContent)
                                    )
                            }
                            Button {

                            } label: {
                                Image(systemName: "mic")
                                    .foregroundStyle(
                                        Color(.subContent)
                                    )
                            }

                            Button {
                                if viewModel.isThinking {
                                    viewModel.stopGeneration()
                                } else {
                                    let textToSend = viewModel.inputText
                                        .trimmingCharacters(
                                            in: .whitespacesAndNewlines
                                        )
                                    guard
                                        !textToSend.isEmpty
                                            || viewModel.selectedUIImage != nil
                                    else { return }
                                    viewModel.sendMessage(textToSend)
                                }
                                KeyboardUtils.closeKeyboard()
                            } label: {
                                Image(
                                    systemName: viewModel.isThinking
                                        ? "stop.fill" : "arrow.up"
                                )
                                .font(
                                    viewModel.isThinking
                                        ? .caption : .body
                                )
                                .fontWeight(.bold)
                                .frame(width: 35, height: 35)
                                .foregroundStyle(
                                    Color(.border)
                                )
                                .background(
                                    viewModel.isThinking
                                        ? Color(.danger)
                                        : Color(.subContent),
                                    in: .circle
                                )
                                .contentTransition(.symbolEffect(.replace))
                                .animation(
                                    .easeInOut(duration: 0.2),
                                    value: viewModel.isThinking
                                )
                            }
                            .disabled(
                                viewModel.isModelLoading
                            )
                        }
                        .foregroundStyle(Color(.primary))
                    }
                }
                .padding(14)
                .background(
                    Color(.info).opacity(0.125),
                    in: .rect(cornerRadius: 20)
                )
                .borderBeam(
                    border: .primary,
                    beam: [.green, .blue, .pink, .orange, .indigo],
                    beamBlur: 20,
                    cornerRadius: 20,
                    isEnabled: !viewModel.isModelLoading
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ChatScreenView()
}
