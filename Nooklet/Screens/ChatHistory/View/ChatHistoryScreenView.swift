//
//  ChatHistoryScreenView.swift
//  Nooklet
//
//  Created by Tu on 23/6/26.
//

import SwiftUI

struct ChatHistoryScreenView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = ChatHistoryScreenViewModel()

    var body: some View {
        ZStack {
            CinematicBackground()
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ],
                    alignment: .leading,
                    spacing: 10
                ) {
                    ForEach(viewModel.chatSessionHistories) {
                        item in
                        ChatHistoryCard(item: item)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Chat History")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func ChatHistoryCard(item: ChatSessionHistory) -> some View {
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
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 150,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .background(Color.black.opacity(0.3))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(BouncyCardStyle())
    }
}
