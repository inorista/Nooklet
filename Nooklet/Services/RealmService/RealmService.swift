import Foundation
import RealmSwift

class RealmService {
    static let shared = RealmService()

    private init() {}

    func saveUser(_ user: UserEntity) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(user)
        }
    }

    func updateUser(_ userModel: User) throws {
        let realm = try Realm()
        if let existingUser = realm.object(ofType: UserEntity.self, forPrimaryKey: userModel.id) {
            try realm.write {
                existingUser.firstName = userModel.firstName
                existingUser.lastName = userModel.lastName
                existingUser.birthDay = userModel.birthDay
                if let imageData = userModel.imageData {
                    existingUser.imageData = imageData
                }
            }
        } else {
            // Fallback to saving if it doesn't exist for some reason
            let newEntity = userModel.toEntity()
            try realm.write {
                realm.add(newEntity)
            }
        }
    }

    func getUser() throws -> UserEntity? {
        let realm = try Realm()
        let user = realm.objects(UserEntity.self).first
        return user
    }

    func createNewChatSession() throws -> ChatSessionEntity {
        let realm = try Realm()
        let newSession = ChatSessionEntity()
        try realm.write {
            realm.add(newSession)
        }
        return newSession
    }

    func saveMessage(
        _ message: ChatMessageEntity,
        to session: ChatSessionEntity
    ) throws {
        let realm = try Realm()
        try realm.write {
            session.messages.append(message)
            session.updatedAt = Date()

            if session.messages.count == 1 || session.title == "New chat" {
                let limit = min(message.content.count, 20)
                let index = message.content.index(
                    message.content.startIndex,
                    offsetBy: limit
                )
                session.title = String(message.content[..<index]) + "..."
            }
        }
    }

    func getChatSessions(_ prefix: Int? = nil) throws -> [ChatSessionEntity] {
        let realm = try Realm()
        let chatSessions = realm.objects(ChatSessionEntity.self).sorted(
            by: \.updatedAt,
            ascending: true
        )
        var result: [ChatSessionEntity] = []
        if prefix != nil {
            result = Array((chatSessions.prefix(prefix!)))
        } else {
            result = Array(chatSessions)
        }
        return result
    }

    func getChatSession(by id: UUID) throws -> ChatSessionEntity? {
        let realm = try Realm()
        return realm.object(ofType: ChatSessionEntity.self, forPrimaryKey: id)
    }

    func deleteChatSession(by id: UUID) throws {
        let realm = try Realm()
        if let session = realm.object(ofType: ChatSessionEntity.self, forPrimaryKey: id) {
            try realm.write {
                realm.delete(session.messages)
                realm.delete(session)
            }
        }
    }
}
