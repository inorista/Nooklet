import Foundation
import SwiftData

@Model
class ChatSession {
    var id: UUID = UUID()
    var title: String = "Chat mới"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    @Relationship(deleteRule: .cascade) 
    var messages: [ChatMessage] = []
    
    init(title: String = "Chat mới") {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
