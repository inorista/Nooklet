//
//  ChatBubbleView.swift
//  Nooklet
//
//  Created by Tu on 21/6/26.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    let isThinking: Bool

    /// Determines if this is the last AI message (used for thinking indicator)
    var isLastAIMessage: Bool = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUserMessage {
                Spacer(minLength: 60)
                userBubble
            } else {
                aiBubble
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
    }

    // MARK: - User Bubble

    private var userBubble: some View {
        VStack(alignment: .trailing, spacing: 6) {
            if let uiImage = message.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if !message.content.isEmpty {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundStyle(Color(.buttonContent))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Color(.button),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
            }
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundStyle(Color(.subContent).opacity(0.6))
        }
    }

    // MARK: - AI Bubble

    private var aiBubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(.nooklet)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .scaledToFit()

                Text("Nooklet")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.content).opacity(0.7))
            }

            if isLastAIMessage && isThinking && message.content == "thinking..." {
                ThinkingIndicatorView()
            } else {
                if let uiImage = message.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 200, maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                if !message.content.isEmpty {
                    Text(message.content)
                        .font(.subheadline)
                        .foregroundStyle(Color(.content))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Color(.surface).opacity(0.6),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .textSelection(.enabled)
                }
            }

            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundStyle(Color(.subContent).opacity(0.6))
        }
    }
}

// MARK: - Thinking Indicator

struct ThinkingIndicatorView: View {
    @State private var dotOffset: [CGFloat] = [0, 0, 0]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(.info).opacity(0.7))
                    .frame(width: 8, height: 8)
                    .offset(y: dotOffset[index])
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            Color(.surface).opacity(0.6),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .onAppear {
            animateDots()
        }
    }

    private func animateDots() {
        for index in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.15)
            ) {
                dotOffset[index] = -6
            }
        }
    }
}
