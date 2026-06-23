//
//  User.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import Foundation
import RealmSwift

class UserEntity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var imageData: String?
    @Persisted var birthDay: Date = Date()

    convenience init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        imageData: String? = nil,
        birthDay: Date
    ) {
        self.init()
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.imageData = imageData
        self.birthDay = birthDay
    }

    func fromModel(_ model: User) -> UserEntity {
        return UserEntity(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            birthDay: self.birthDay,
        )
    }

    func toModel() -> User {
        return User(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            imageData: self.imageData,
            birthDay: self.birthDay
        )
    }
}
