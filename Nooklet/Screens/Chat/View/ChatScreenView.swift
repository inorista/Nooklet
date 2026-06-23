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
    @State private var animateBackground = false
    @State private var animatePulse = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CinematicBackground()
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
        .sheet(isPresented: $viewModel.showDeleteSheet) {
            DeleteConfirmationSheet()
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(
                selectedImage: Binding(
                    get: { viewModel.selectedUIImage },
                    set: { viewModel.setSelectedImage(uiImage: $0) }
                ),
                sourceType: viewModel.imageSourceType
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.currentSession != nil {
                    Button(
                        role: .destructive,
                        action: {
                            viewModel.showDeleteSheet = true
                        }
                    ) {
                        Label("Delete", systemImage: "trash")
                            .foregroundStyle(Color(.danger))
                    }
                }
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 10.0).repeatForever(autoreverses: true)
            ) {
                animateBackground = true
            }
            withAnimation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
            ) {
                animatePulse = true
            }
        }
    }

    // MARK: - Chat Body Content

    @ViewBuilder
    func ChatBodyContent() -> some View {
        switch viewModel.modelInitStatus {
        case .loading:
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 4)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: 0.6)
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue, Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(animateBackground ? 360 : 0))
                        .animation(
                            .linear(duration: 1.5).repeatForever(
                                autoreverses: false
                            ),
                            value: animateBackground
                        )
                }

                VStack(spacing: 8) {
                    Text("Nooklet Engine")
                        .font(
                            .system(size: 18, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text(viewModel.modelInitStatus.displayStatus)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(.content).opacity(0.6))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            .padding(32)
            .background(Color.black.opacity(0.3))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

        case .failed:
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(.danger))
                    .shadow(color: Color(.danger).opacity(0.4), radius: 8)

                Text("Initialization Failed")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(viewModel.modelInitStatus.displayStatus)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.subContent))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(32)
            .background(Color.black.opacity(0.3))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 100)

        case .loaded:
            if viewModel.messages.isEmpty {
                VStack(spacing: 40) {
                    Spacer()

                    // Pulsing breathing logo
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 130, height: 130)
                            .scaleEffect(animatePulse ? 1.15 : 0.95)
                            .blur(radius: 15)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.1),
                                        Color.purple.opacity(0.2),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 110)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.4),
                                                Color.purple.opacity(0.1),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )

                        Image(.nooklet)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .shadow(color: .blue.opacity(0.5), radius: 10)
                    }
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0).repeatForever(
                                autoreverses: true
                            )
                        ) {
                            animatePulse = true
                        }
                    }

                    // Welcome Title
                    VStack(spacing: 8) {
                        Text("Nooklet Studio")
                            .font(
                                .system(
                                    size: 32,
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

                        Text("ON-DEVICE AI • SECURE & PRIVATE")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2.0)
                            .foregroundStyle(Color.blue)

                        Text(
                            "Your messages are compiled and generated locally using Gemma 4 (2B) and transcribing with Nemotron 3.5 ASR."
                        )
                        .lineLimit(2)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(.subContent).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 4)
                        .lineSpacing(4)
                    }

                    // Dynamic Suggestion Cards
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GET STARTED")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2.0)
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.leading, 8)

                        let suggestions = [
                            (
                                "sparkles", "Offline assistant",
                                "Brainstorm ideas, rewrite text, or ask general questions locally."
                            ),
                            (
                                "bubble.left.and.bubble.right.fill",
                                "Practice language",
                                "Say something in English/Vietnamese to translate or practice."
                            ),
                        ]

                        ForEach(suggestions, id: \.1) { icon, title, desc in
                            Button {
                                UIImpactFeedbackGenerator(style: .light)
                                    .impactOccurred()
                                viewModel.inputText = title
                            } label: {
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: icon)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background(
                                            Color.white.opacity(0.08),
                                            in: Circle()
                                        )
                                        .overlay(
                                            Circle().stroke(
                                                Color.white.opacity(0.1),
                                                lineWidth: 1
                                            )
                                        )

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(title)
                                            .font(
                                                .system(
                                                    size: 14,
                                                    weight: .bold,
                                                    design: .rounded
                                                )
                                            )
                                            .foregroundStyle(.white)
                                        Text(desc)
                                            .font(.system(size: 12))
                                            .foregroundStyle(
                                                .white.opacity(0.4)
                                            )
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(14)
                                .background(Color.white.opacity(0.03))
                                .background(.ultraThinMaterial)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 18,
                                        style: .continuous
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(
                                        cornerRadius: 18,
                                        style: .continuous
                                    )
                                    .strokeBorder(
                                        Color.white.opacity(0.05),
                                        lineWidth: 1
                                    )
                                )
                            }
                            .buttonStyle(BouncyCardStyle())
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 140)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
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
                    .onAppear {
                        DispatchQueue.main.async {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(
                                    "bottom_anchor",
                                    anchor: .bottom
                                )
                            }
                        }
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

    // MARK: - Cinematic Background
    @ViewBuilder
    func CinematicBackground() -> some View {
        ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.05)  // Deep premium dark background

            GeometryReader { geo in
                ZStack {
                    // Accent Glow 1
                    Circle()
                        .fill(Color.blue.opacity(animateBackground ? 0.2 : 0.1))
                        .frame(width: geo.size.width * 1.3)
                        .blur(radius: 130)
                        .offset(
                            x: animateBackground
                                ? -geo.size.width * 0.3 : -geo.size.width * 0.5,
                            y: animateBackground
                                ? -geo.size.height * 0.2
                                : -geo.size.height * 0.3
                        )

                    // Accent Glow 2
                    Circle()
                        .fill(
                            Color.purple.opacity(
                                animateBackground ? 0.15 : 0.05
                            )
                        )
                        .frame(width: geo.size.width * 1.1)
                        .blur(radius: 110)
                        .offset(
                            x: animateBackground
                                ? geo.size.width * 0.4 : geo.size.width * 0.6,
                            y: animateBackground
                                ? geo.size.height * 0.4 : geo.size.height * 0.5
                        )
                }
            }
            .drawingGroup()  // Optimize rendering
        }
        .ignoresSafeArea()
    }

    // MARK: - Text Field Chat

    @ViewBuilder
    func TextFieldChat() -> some View {
        ZStack(alignment: .bottom) {
            // Soft transparent bottom gradient
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.03, blue: 0.05).opacity(0),
                    Color(red: 0.03, green: 0.03, blue: 0.05).opacity(0.85),
                    Color(red: 0.03, green: 0.03, blue: 0.05),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 160)
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 12) {
                // Speech recording status overlay
                if viewModel.isRecordingSpeech {
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.red)
                                .frame(
                                    width: 3,
                                    height: animatePulse
                                        ? CGFloat.random(in: 10...25)
                                        : CGFloat.random(in: 4...12)
                                )
                        }
                        Text("Listening Offline...")
                            .font(
                                .system(
                                    size: 13,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().strokeBorder(
                            Color.red.opacity(0.2),
                            lineWidth: 1
                        )
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.6).repeatForever(
                                autoreverses: true
                            )
                        ) {
                            animatePulse = true
                        }
                    }
                }

                // Image preview inside input container
                if let selectedImage = viewModel.selectedUIImage {
                    HStack {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.white.opacity(0.15),
                                            lineWidth: 1
                                        )
                                )

                            Button {
                                viewModel.clearSelectedImage()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color(.danger))
                                    .background(Color.black, in: .circle)
                            }
                            .offset(x: 6, y: -6)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.scale.combined(with: .opacity))
                }

                // Inner input panel
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .bottom, spacing: 12) {
                        TextField(
                            "",
                            text: $viewModel.inputText,
                            prompt: Text("Ask anything...")
                                .foregroundColor(.white.opacity(0.4))
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .medium,
                                        design: .rounded
                                    )
                                ),
                            axis: .vertical
                        )
                        .lineLimit(1...8)
                        .disabled(viewModel.isModelLoading)
                        .foregroundStyle(.white)
                        .font(
                            .system(size: 15, weight: .medium, design: .rounded)
                        )
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)

                        if !viewModel.inputText.isEmpty {
                            Button {
                                viewModel.inputText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.3))
                                    .font(.system(size: 16))
                            }
                            .padding(.bottom, 8)
                        }
                    }

                    HStack(alignment: .center, spacing: 16) {
                        // Interactive Model Selection Menu
                        Menu {
                            ForEach(viewModel.availableModels) { model in
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium)
                                        .impactOccurred()
                                    Task {
                                        await viewModel.switchModel(to: model)
                                    }
                                } label: {
                                    HStack {
                                        Text(model.displayName)
                                        if model
                                            == viewModel.selectedModelIdentifier
                                        {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "cpu")
                                    .font(.system(size: 12, weight: .bold))
                                Text(
                                    viewModel.selectedModelIdentifier
                                        .displayName
                                )
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        Color.white.opacity(0.12),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .disabled(viewModel.isModelLoading)

                        Spacer()

                        // Action buttons
                        HStack(spacing: 12) {
                            Menu {
                                Button {
                                    #if targetEnvironment(simulator)
                                        viewModel.imageSourceType =
                                            .photoLibrary
                                    #else
                                        if UIImagePickerController
                                            .isSourceTypeAvailable(.camera)
                                        {
                                            viewModel.imageSourceType = .camera
                                        } else {
                                            viewModel.imageSourceType =
                                                .photoLibrary
                                        }
                                    #endif
                                    viewModel.showImagePicker = true
                                } label: {
                                    Label(
                                        "Take Photo",
                                        systemImage: "camera.fill"
                                    )
                                }

                                Button {
                                    viewModel.imageSourceType = .photoLibrary
                                    viewModel.showImagePicker = true
                                } label: {
                                    Label(
                                        "Choose from Library",
                                        systemImage: "photo.on.rectangle.angled"
                                    )
                                }
                            } label: {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 18))
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .background(
                                        Color.white.opacity(0.06),
                                        in: Circle()
                                    )
                                    .overlay(
                                        Circle().strokeBorder(
                                            Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                    )
                            }
                            .buttonStyle(BouncyCardStyle())

                            Button {
                                UIImpactFeedbackGenerator(style: .rigid)
                                    .impactOccurred()
                                viewModel.toggleSpeechRecording()
                            } label: {
                                ZStack {
                                    if viewModel.isRecordingSpeech {
                                        Circle()
                                            .stroke(
                                                Color.red.opacity(0.4),
                                                lineWidth: 2
                                            )
                                            .scaleEffect(
                                                animatePulse ? 1.4 : 1.0
                                            )
                                            .opacity(animatePulse ? 0.0 : 1.0)
                                    }

                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 18))
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(
                                            viewModel.isRecordingSpeech
                                                ? .white : .white.opacity(0.7)
                                        )
                                        .background(
                                            viewModel.isRecordingSpeech
                                                ? Color.red
                                                : Color.white.opacity(0.06),
                                            in: Circle()
                                        )
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    viewModel.isRecordingSpeech
                                                        ? Color.red
                                                        : Color.white.opacity(
                                                            0.1
                                                        ),
                                                    lineWidth: 1
                                                )
                                        )
                                }
                            }
                            .buttonStyle(BouncyCardStyle())

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
                                    .system(
                                        size: viewModel.isThinking ? 14 : 16,
                                        weight: .bold
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.white)
                                .background(
                                    viewModel.isThinking
                                        ? Color.red : Color.blue,
                                    in: Circle()
                                )
                                .shadow(
                                    color: (viewModel.isThinking
                                        ? Color.red : Color.blue).opacity(0.4),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            }
                            .disabled(viewModel.isModelLoading)
                            .buttonStyle(BouncyCardStyle())
                        }
                    }
                }
                .padding(16)
                .background(
                    Color(.black).opacity(0.25),
                    in: .rect(cornerRadius: 20)
                )
                .borderBeam(
                    border: .white.opacity(0.35),
                    beam: [.blue, .purple, .pink, .indigo],
                    beamBlur: 20,
                    cornerRadius: 20,
                    isEnabled: !viewModel.isModelLoading
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    func DeleteConfirmationSheet() -> some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.border).opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                Image(systemName: "trash.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Color(.danger), in: .circle)
                    .shadow(
                        color: Color(.danger).opacity(0.35),
                        radius: 8,
                        x: 0,
                        y: 4
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Delete Conversation?")
                        .font(
                            .system(size: 20, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(Color(.content))

                    Text(
                        "This conversation will be permanently removed. You cannot undo this action."
                    )
                    .font(.caption)
                    .foregroundStyle(Color(.subContent))
                }
            }
            .padding(.horizontal, 24)

            if let session = viewModel.currentSession {
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.content))
                        .lineLimit(1)

                    let textPreview =
                        viewModel.messages.first(where: { !$0.isUserMessage })?
                        .content ?? ""
                    if !textPreview.isEmpty {
                        Text(textPreview)
                            .font(.caption2)
                            .foregroundStyle(Color(.subContent))
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(.historyCard).opacity(0.4))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.border).opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            }

            HStack(spacing: 16) {
                Button {
                    viewModel.showDeleteSheet = false
                } label: {
                    Text("Cancel")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.content))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(.border), lineWidth: 1.5)
                        )
                }

                Button {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    viewModel.deleteCurrentSession()
                    viewModel.showDeleteSheet = false
                } label: {
                    Text("Delete")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Color(.danger),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .shadow(
                            color: Color(.danger).opacity(0.3),
                            radius: 6,
                            x: 0,
                            y: 3
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .presentationDetents([.fraction(0.38)])
        .presentationDragIndicator(.hidden)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.radientPrimary), Color(.radientSecondary),
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    ChatScreenView()
}
