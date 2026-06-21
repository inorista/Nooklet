//
//  ChatScreenView.swift
//  Nooklet
//
//  Created by Tu on 21/6/26.
//

import SwiftUI

struct ChatScreenView: View {
    @StateObject private var viewModel: ChatViewModel = ChatViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            RadientBackground()
            TextFieldChat()
        }
        .navigationTitle("New Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

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

    @ViewBuilder
    func TextFieldChat() -> some View {
        VStack {
            VStack(alignment: .leading, spacing: 25) {
                TextField(
                    "",
                    text: .constant(""),
                    prompt: Text("Ask Anything....")
                        .foregroundColor(Color(.content).opacity(0.7))
                        .font(.callout)
                )
                .disabled(viewModel.isModelLoading)
                .padding(.top, 8)
                .foregroundStyle(Color(.content))
                HStack(alignment: .center, spacing: 20) {
                    Button {
                        print("OK")
                    } label: {
                        Text("Model: Gemma 4")
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

                        } label: {
                            Image(systemName: "arrow.up")
                                .frame(width: 35, height: 35)
                                .foregroundStyle(
                                    Color(.border)
                                )
                                .background(
                                    Color(.subContent),
                                    in: .circle
                                )
                        }
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
                isEnabled: !viewModel.isModelLoading,
            )
        }
        .padding()
    }
}

#Preview {
    ChatScreenView()
}
