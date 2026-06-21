import Foundation
import RealmSwift



class RealmService {
    static let shared = RealmService()

    private init() {}


    func saveUser(_ user: User) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(user)
        }
    }

    func getUser() throws -> User? {
        let realm = try Realm()
        return realm.objects(User.self).first
    }


    func createNewChatSession() throws -> ChatSession {
        let realm = try Realm()
        let newSession = ChatSession()
        try realm.write {
            realm.add(newSession)
        }
        return newSession
    }

    func saveMessage(_ message: ChatMessage, to session: ChatSession) throws {
        let realm = try Realm()
        try realm.write {
            session.messages.append(message)
            session.updatedAt = Date()

            if session.messages.count == 1 || session.title == "Chat mới" {
                let limit = min(message.content.count, 20)
                let index = message.content.index(
                    message.content.startIndex,
                    offsetBy: limit
                )
                session.title = String(message.content[..<index]) + "..."
            }
        }
    }

    func getLatestChatSession() throws -> ChatSession? {
        let realm = try Realm()
        return realm.objects(ChatSession.self).sorted(
            byKeyPath: "updatedAt",
            ascending: false
        ).first
    }
}
