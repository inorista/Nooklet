//
//  MessageModel.swift
//  Nooklet
//
//  Created by Tu on 16/6/26.
//

import Foundation
import SwiftUI

/// Represents a single message in the chat, including content, sender, timestamp, and an optional image.
struct Message: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUserMessage: Bool
    let timestamp: Date
    let uiImage: UIImage? // Optional image for the message

    init(id: UUID = UUID(), content: String, isUserMessage: Bool, timestamp: Date = Date(), uiImage: UIImage? = nil) {
        self.id = id
        self.content = content
        self.isUserMessage = isUserMessage
        self.timestamp = timestamp
        self.uiImage = uiImage
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUserMessage == rhs.isUserMessage && lhs.timestamp == rhs.timestamp && lhs.uiImage == rhs.uiImage
    }
}
