import SwiftUI

struct ExploreScreenView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var vm = ExploreViewModel()
    @State private var isAnimatingCTA = false

    var body: some View {
        ZStack {
            CinematicBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    // Hero Section
                    VStack(spacing: 24) {
                        Text("Give your words\na voice.")
                            .font(
                                .system(
                                    size: 32,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .tracking(1.2)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 60)

                        // Giant CTA Button
                        Button {
                            UIImpactFeedbackGenerator(style: .rigid)
                                .impactOccurred()
                            coordinator.push(.speech)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "waveform")
                                        .font(.system(size: 20, weight: .bold))
                                        .symbolEffect(
                                            .variableColor.iterative.reversing
                                        )
                                }

                                Text("Generate Voice Now")
                                    .font(.title3.weight(.bold))
                                    .tracking(0.5)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [
                                            Color(
                                                red: 1.0,
                                                green: 0.15,
                                                blue: 0.35
                                            ),
                                            Color(
                                                red: 1.0,
                                                green: 0.4,
                                                blue: 0.1
                                            ),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(
                                color: Color(red: 1.0, green: 0.15, blue: 0.35)
                                    .opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                            .scaleEffect(isAnimatingCTA ? 1.02 : 0.98)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(
                                    autoreverses: true
                                ),
                                value: isAnimatingCTA
                            )
                        }
                        .buttonStyle(BouncyCardStyle())
                        .padding(.horizontal, 24)
                        .onAppear {
                            isAnimatingCTA = true
                        }
                    }

                    // Bento Grid Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Voice Library")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16),
                            ],
                            spacing: 16
                        ) {
                            ForEach(vm.voiceSamples) { sample in
                                VoiceSampleCard(
                                    sample: sample,
                                    isPlaying: vm.playingSampleId == sample.id
                                ) {
                                    UIImpactFeedbackGenerator(style: .light)
                                        .impactOccurred()
                                    vm.togglePlay(for: sample)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 80)
                }
            }
        }
    }
}

struct VoiceSampleCard: View {
    let sample: VoiceSample
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Image(sample.avatar)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                        if isPlaying {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 52, height: 52)
                                .scaleEffect(1.1)
                                .animation(
                                    .easeInOut(duration: 1).repeatForever(),
                                    value: isPlaying
                                )
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(sample.author)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Image(
                                systemName: isPlaying
                                    ? "speaker.wave.2.fill" : "play.circle.fill"
                            )
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(
                                isPlaying ? .green : .white.opacity(0.6)
                            )
                            .symbolEffect(
                                .bounce,
                                options: .repeating,
                                isActive: isPlaying
                            )

                            Text(isPlaying ? "Playing" : "Preview")
                                .font(.caption2.weight(.medium))
                                .foregroundColor(
                                    isPlaying ? .green : .white.opacity(0.6)
                                )
                        }
                    }
                    Spacer(minLength: 0)
                }

                Text(sample.content)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .lineLimit(4)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
            }
            .padding(16)
            .frame(height: 180)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.07),
                            Color.white.opacity(0.02),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    if isPlaying {
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.green.opacity(0.15), Color.clear,
                            ]),
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 100
                        )
                    }
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: isPlaying
                                ? [.green.opacity(0.8), .green.opacity(0.3)]
                                : [.white.opacity(0.15), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isPlaying ? 1.5 : 1
                    )
            )
            .shadow(
                color: isPlaying
                    ? Color.green.opacity(0.2) : Color.black.opacity(0.15),
                radius: 10,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(BouncyCardStyle())
    }
}

#Preview {
    ExploreScreenView()
}
