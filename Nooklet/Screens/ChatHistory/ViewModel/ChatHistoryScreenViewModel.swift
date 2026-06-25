//
//  ChatHistoryScreenViewModel.swift
//  Nooklet
//
//  Created by Tu on 23/6/26.
//

import Foundation

@MainActor
class ChatHistoryScreenViewModel: ObservableObject {
    @Published var chatSessionHistories: [ChatSessionHistory] = []

    init() {
        fetchChatSessionHistories()
    }

    private func fetchChatSessionHistories() {
        do {
            let chatSessionEntites: [ChatSessionEntity] =
                try RealmService.shared.getChatSessions()

            let chatSessionHistories =
                chatSessionEntites.map {
                    item in
                    item.toChatSessionHistoryModel()
                }

            self.chatSessionHistories = chatSessionHistories
        } catch {
            print("Fetch chat session failed")
        }

    }
}
