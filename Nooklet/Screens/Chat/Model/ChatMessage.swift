import Foundation
import SwiftData
import SwiftUI

@Model
class ChatMessage {
    var id: UUID = UUID()
    var content: String = ""
    var isUserMessage: Bool = true
    var timestamp: Date = Date()
    
    // CoreData/SwiftData handles Data natively. We store the UIImage as Data (PNG or JPEG)
    var imageData: Data?
    
    // Reference back to session
    var session: ChatSession?
    
    init(content: String, isUserMessage: Bool, imageData: Data? = nil) {
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
