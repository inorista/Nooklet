import Foundation
import RealmSwift

class ChatSessionEntity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var title: String = "Chat mới"
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var messages: List<ChatMessageEntity>

    convenience init(title: String = "Chat mới") {
        self.init()
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func toHomeChatSessionModel() -> HomeChatSession {
        return HomeChatSession(
            id: self.id,
            title: self.title,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            firstAnswer: messages.isEmpty
                ? nil
                : messages.first(where: { !$0.isUserMessage })?.content ?? ""
        )
    }

    func toChatSessionHistoryModel() -> ChatSessionHistory {
        return ChatSessionHistory(
            id: self.id,
            title: self.title,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            firstAnswer: messages.isEmpty
                ? nil
                : messages.first(where: { !$0.isUserMessage })?.content ?? ""
        )
    }
}
