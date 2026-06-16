import SwiftUI

struct RecordingScreen: View {
    @State private var viewModel = RecordingViewModel()

    /// Dark background base
    private let bgColor = Color(red: 0.05, green: 0.05, blue: 0.08)

    var body: some View {
        ZStack {
            // 1. Ambient mesh-like background
            ambientBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Language picker — top area
                HStack {
                    glassLanguagePicker
                    Spacer()
                    if viewModel.status.isBusy {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Centered voice orb
                VoiceOrbView(
                    audioLevel: viewModel.audioLevel,
                    isRecording: viewModel.isRecording,
                    elapsedText: viewModel.elapsedFormatted,
                    onTap: {
                        Task { await viewModel.toggleRecording() }
                    }
                )

                Spacer()

                // Transcript area — bottom
                TranscriptView(
                    partial: viewModel.partialTranscript, final: viewModel.finalTranscript
                )
            }
            .padding(.bottom, 90) // Increased to accommodate the MorphingTabBar
        }
        .navigationTitle("Nooklet")
        .navigationBarTitleDisplayMode(.inline)
        // Make navigation bar transparent to let ambient background show through
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.onAppear()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isRecording)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.partialTranscript.isEmpty)
    }

    // MARK: - Ambient Background

    private var ambientBackground: some View {
        ZStack {
            bgColor

            // Soft glowing orbs in the corners to simulate a mesh gradient
            Circle()
                .fill(Color(red: 0.2, green: 0.1, blue: 0.5).opacity(0.4))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: -150, y: -300)

            Circle()
                .fill(Color(red: 0.1, green: 0.3, blue: 0.5).opacity(0.3))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(x: 200, y: 300)
                
            Circle()
                .fill(Color(red: 0.4, green: 0.1, blue: 0.3).opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 100, y: -100)
        }
    }

    // MARK: - Language Picker

    private var glassLanguagePicker: some View {
        Menu {
            Picker(
                "Language",
                selection: Binding(
                    get: { viewModel.selectedLanguage },
                    set: { viewModel.setLanguage($0) }
                )
            ) {
                ForEach(ASRLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .medium))
                Text(viewModel.selectedLanguage.displayName)
                    .font(.system(size: 14, weight: .medium))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear, .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
        }
        .disabled(viewModel.isSessionActive)
        .opacity(viewModel.isSessionActive ? 0.6 : 1.0)
    }

    // MARK: - Transcript Section

    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.partialTranscript.isEmpty {
                Text(viewModel.partialTranscript)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineSpacing(4)
                    .lineLimit(3)
                    // Subtle glow for the live text
                    .shadow(color: .white.opacity(0.2), radius: 2)
            }

            if !viewModel.finalTranscript.isEmpty {
                if !viewModel.partialTranscript.isEmpty {
                    Divider()
                        .background(.white.opacity(0.2))
                }
                
                ScrollView {
                    Text(viewModel.finalTranscript)
                        .font(.body.weight(.regular))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 180)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Premium Glass Card effect
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.05), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 15, y: 10)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        RecordingScreen()
    }
}
