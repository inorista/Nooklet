//
//  HomeViewModel.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import Foundation
import RealmSwift
import SwiftUI
import UIKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var greeting: String = "Good morning,"
    @Published private(set) var chatSessions: [HomeChatSession] = []
    @Published var user: User?

    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<5:
            return "Good night,"
        case 5..<12:
            return "Good morning,"
        case 12..<18:
            return "Good afternoon,"
        default:
            return "Good morning,"
        }
    }

    init() {
        self.greeting = getGreeting()
    }

    private func loadChatHistories() -> [HomeChatSession] {
        do {
            let chatSessions: [ChatSessionEntity] =
                try RealmService.shared.getChatSessions(10)

            let homeChatSessions: [HomeChatSession] = chatSessions.map {
                $0.toHomeChatSessionModel()
            }
            return homeChatSessions
        } catch {
            return []
        }
    }

    private func loadUser() -> User? {
        do {
            let userEntity = try RealmService.shared.getUser()
            let user = userEntity?.toModel()
            return user
        } catch {
            return nil
        }
    }

    public func initData() async {
        chatSessions = loadChatHistories()
        user = loadUser()
    }
}
