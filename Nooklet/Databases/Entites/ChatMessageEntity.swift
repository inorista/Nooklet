import Foundation
import RealmSwift
import SwiftUI

class ChatMessageEntity: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var id: UUID = UUID()
    @Persisted var content: String = ""
    @Persisted var isUserMessage: Bool = true
    @Persisted var timestamp: Date = Date()
    @Persisted var imageData: Data?
    
    convenience init(content: String, isUserMessage: Bool, imageData: Data? = nil) {
        self.init()
        self.id = UUID()
        self.content = content
        self.isUserMessage = isUserMessage
        self.timestamp = Date()
        self.imageData = imageData
    }
    
    var uiImage: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }

    func toModel() -> ChatMessage {
        return ChatMessage(
            id: id,
            content: content,
            isUserMessage: isUserMessage,
            timestamp: timestamp,
            uiImage: uiImage
        )
    }

    static func fromModel(_ model: ChatMessage) -> ChatMessageEntity {
        let entity = ChatMessageEntity()
        entity.id = model.id
        entity.content = model.content
        entity.isUserMessage = model.isUserMessage
        entity.timestamp = model.timestamp
        if let uiImage = model.uiImage {
            entity.imageData = uiImage.jpegData(compressionQuality: 0.8)
        }
        return entity
    }
}
