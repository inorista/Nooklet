import Foundation
import RealmSwift
import SwiftUI

class ChatMessage: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var content: String = ""
    @Persisted var isUserMessage: Bool = true
    @Persisted var timestamp: Date = Date()
    
    // CoreData/SwiftData/Realm handles Data natively. We store the UIImage as Data (PNG or JPEG)
    @Persisted var imageData: Data?
    
    // Reference back to session
    @Persisted(originProperty: "messages") var session: LinkingObjects<ChatSession>
    
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
}
