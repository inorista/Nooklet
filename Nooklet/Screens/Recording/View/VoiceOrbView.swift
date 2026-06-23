import SwiftUI

/// A premium, animated voice orb that reacts to microphone audio levels.
///
/// Features a vibrant glassmorphism aesthetic with 4 rotating blob layers,
/// additive blend modes for a neon glow, and dynamic audio-reactive scaling.
struct VoiceOrbView: View {
    let audioLevel: Float
    let isRecording: Bool
    let elapsedText: String
    var onTap: () -> Void

    // MARK: - Animation state

    @State private var rotation1: Double = 0
    @State private var rotation2: Double = 0
    @State private var rotation3: Double = 0
    @State private var rotation4: Double = 0
    @State private var smoothLevel: CGFloat = 0

    // MARK: - Constants

    private let orbSize: CGFloat = 200
    private let innerCircleRatio: CGFloat = 0.75
    
    // Cyber/Neon Glow Palette
    private let colorDeepPurple = Color(red: 0.35, green: 0.15, blue: 0.85) // Dark Purple
    private let colorMagenta = Color(red: 0.90, green: 0.10, blue: 0.60)    // Hot Magenta
    private let colorCyan = Color(red: 0.10, green: 0.80, blue: 0.95)       // Bright Cyan
    private let colorBlue = Color(red: 0.15, green: 0.35, blue: 0.95)       // Vivid Blue

    var body: some View {
        ZStack {
            // Blob layer 4 (Outermost, largest, soft blue glow)
            blobLayer(
                rotation: rotation4,
                scaleX: 0.88,
                scaleY: 0.96,
                color1: colorBlue,
                color2: colorDeepPurple,
                extraScale: 1.25,
                blurRadius: 18,
                opacity: 0.4
            )

            // Blob layer 3 (Magenta/Cyan mix)
            blobLayer(
                rotation: rotation3,
                scaleX: 0.95,
                scaleY: 0.85,
                color1: colorMagenta,
                color2: colorCyan,
                extraScale: 1.15,
                blurRadius: 14,
                opacity: 0.5
            )

            // Blob layer 2 (Deep Purple/Blue mix)
            blobLayer(
                rotation: rotation2,
                scaleX: 0.82,
                scaleY: 0.92,
                color1: colorDeepPurple,
                color2: colorBlue,
                extraScale: 1.08,
                blurRadius: 10,
                opacity: 0.6
            )

            // Blob layer 1 (Innermost, brightest core)
            blobLayer(
                rotation: rotation1,
                scaleX: 0.95,
                scaleY: 0.95,
                color1: colorCyan,
                color2: colorMagenta,
                extraScale: 1.02,
                blurRadius: 6,
                opacity: 0.7
            )

            // Inner dark glass circle (Floating Button)
            innerGlassCircle

            // Center content: mic icon or timer
            centerContent
        }
        .frame(width: orbSize * 1.5, height: orbSize * 1.5)
        .contentShape(Circle())
        .onTapGesture {
            // Add a subtle tactile tap feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onTap()
        }
        .onAppear { startAnimations() }
        .onChange(of: audioLevel) { _, newLevel in
            // Exaggerated spring animation for voice responsiveness
            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.6)) {
                smoothLevel = CGFloat(newLevel)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var innerGlassCircle: some View {
        let size = orbSize * innerCircleRatio
        
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.10, green: 0.10, blue: 0.18).opacity(0.8),
                        Color(red: 0.05, green: 0.05, blue: 0.10).opacity(0.95)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            // Inner shadow for depth
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear, .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            // Outer glow from the button itself
            .shadow(color: colorDeepPurple.opacity(isRecording ? 0.6 : 0.3), radius: 15, x: 0, y: 0)
    }

    @ViewBuilder
    private var centerContent: some View {
        if isRecording {
            Text(elapsedText)
                .font(.system(size: 38, weight: .light, design: .monospaced))
                .foregroundStyle(.white)
                // Text glow
                .shadow(color: colorCyan.opacity(0.5), radius: 6)
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
        } else {
            Image(systemName: "mic.fill")
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                // Icon glow
                .shadow(color: colorMagenta.opacity(0.6), radius: 8)
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
        }
    }

    @ViewBuilder
    private func blobLayer(
        rotation: Double,
        scaleX: CGFloat,
        scaleY: CGFloat,
        color1: Color,
        color2: Color,
        extraScale: CGFloat,
        blurRadius: CGFloat,
        opacity: Double
    ) -> some View {
        // More dramatic pulse based on audio level
        let levelPulse = 1.0 + smoothLevel * 0.35
        let size = orbSize * extraScale

        Ellipse()
            .fill(
                LinearGradient(
                    colors: [color1, color2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size * scaleX, height: size * scaleY)
            .scaleEffect(levelPulse)
            .rotationEffect(.degrees(rotation))
            .blur(radius: blurRadius)
            .opacity(opacity)
            .blendMode(.plusLighter) // Magic neon glowing effect when layers overlap
    }

    // MARK: - Animations

    private func startAnimations() {
        // 4 separate layers rotating at different speeds, directions, and phases
        withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
            rotation1 = 360
        }
        withAnimation(.linear(duration: 11).repeatForever(autoreverses: false)) {
            rotation2 = -360
        }
        withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
            rotation3 = 360
        }
        withAnimation(.linear(duration: 19).repeatForever(autoreverses: false)) {
            rotation4 = -360
        }
    }
}

// MARK: - Preview

#Preview("Idle") {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.08)
            .ignoresSafeArea()

        VoiceOrbView(
            audioLevel: 0,
            isRecording: false,
            elapsedText: "00:00",
            onTap: {}
        )
    }
}

#Preview("Recording") {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.08)
            .ignoresSafeArea()

        VoiceOrbView(
            audioLevel: 0.6,
            isRecording: true,
            elapsedText: "00:40",
            onTap: {}
        )
    }
}
