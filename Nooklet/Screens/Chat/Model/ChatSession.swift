import Foundation
import RealmSwift

class ChatSession: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var title: String = "Chat mới"
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    
    @Persisted var messages: List<ChatMessage>
    
    convenience init(title: String = "Chat mới") {
        self.init()
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
