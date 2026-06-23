//
//  ChatHistory.swift
//  Nooklet
//
//  Created by Tu on 22/6/26.
//

import Foundation
import SwiftUI

struct HomeChatSession: Identifiable, Equatable {
    let id: UUID
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let firstAnswer: String?

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        firstAnswer: String? = ""
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.firstAnswer = firstAnswer
    }

    static func == (lhs: HomeChatSession, rhs: HomeChatSession) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
            && lhs.createdAt == rhs.createdAt && lhs.updatedAt == rhs.updatedAt
            && lhs.firstAnswer == rhs.firstAnswer
    }
}
