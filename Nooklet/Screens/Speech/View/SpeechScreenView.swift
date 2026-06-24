import SwiftUI

struct SpeechScreenView: View {
    @StateObject private var vm = SpeechScreenViewModel()

    var body: some View {
        ZStack {
            CinematicBackground()
            SpeechBodyContent()
        }
        .onTapGesture {
            KeyboardUtils.closeKeyboard()
        }
        .onAppear {
            Task {
                vm.startup()
            }
        }
        .navigationTitle("Supertonic")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func SpeechBodyContent() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                TextEditor(text: $vm.text)
                    .frame(minHeight: 120, maxHeight: 180)
                    .padding(12)
                    .scrollContentBackground(.hidden)
                    .background(Color.black.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )

                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Text("NFE")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                        Slider(value: $vm.nfe, in: 2...15, step: 1)
                            .tint(.white)
                        Text("\(Int(vm.nfe))")
                            .font(
                                .subheadline.monospacedDigit().weight(
                                    .semibold
                                )
                            )
                            .foregroundColor(.white)
                            .frame(width: 36)
                    }

                    HStack {
                        Text("Voice")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Picker("Voice", selection: $vm.voice) {
                            ForEach(
                                SupertonicService.Voice.allCases,
                                id: \.self
                            ) { v in
                                Text(v.rawValue).tag(v)
                            }
                        }
                        .tint(.white)
                    }

                    HStack {
                        Text("Language")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Picker("Language", selection: $vm.language) {
                            ForEach(
                                SupertonicService.Language.allCases,
                                id: \.self
                            ) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .tint(.white)
                    }
                }
                .padding(20)
                .background(Color.black.opacity(0.3))
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)

            HStack(spacing: 16) {
                Button {
                    UIImpactFeedbackGenerator(style: .rigid)
                        .impactOccurred()
                    vm.generate()
                } label: {
                    HStack {
                        Image(
                            systemName: vm.isGenerating
                                ? "hourglass" : "wand.and.stars"
                        )
                        Text(vm.isGenerating ? "Generating..." : "Generate")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .background(.ultraThinMaterial)
                    .foregroundColor(.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(BouncyCardStyle())
                .disabled(vm.isGenerating)
                .opacity(vm.isGenerating ? 0.5 : 1)

                Button {
                    UIImpactFeedbackGenerator(style: .light)
                        .impactOccurred()
                    vm.togglePlay()
                } label: {
                    HStack {
                        Image(
                            systemName: vm.isPlaying
                                ? "stop.fill" : "play.fill"
                        )
                        Text(vm.isPlaying ? "Stop" : "Play")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Color.white.opacity(vm.isPlaying ? 0.2 : 0.05)
                    )
                    .background(.ultraThinMaterial)
                    .foregroundColor(.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .buttonStyle(BouncyCardStyle())
                .disabled(vm.audioURL == nil)
                .opacity(vm.audioURL == nil ? 0.5 : 1)

                if let url = vm.audioURL {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 56, height: 54)
                            .background(Color.white.opacity(0.1))
                            .background(.ultraThinMaterial)
                            .foregroundColor(.white)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16,
                                    style: .continuous
                                )
                            )
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: 16,
                                    style: .continuous
                                )
                                .strokeBorder(
                                    .white.opacity(0.15),
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(BouncyCardStyle())
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(
                .spring(response: 0.4, dampingFraction: 0.7),
                value: vm.audioURL
            )
            .padding(.horizontal, 24)

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red.opacity(0.8))
                    .font(.footnote.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
    }
}
