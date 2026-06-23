//
//  User.swift
//  Nooklet
//
//  Created by Tu on 23/6/26.
//

import Foundation

struct User: Identifiable, Equatable {
    let id: UUID
    let firstName: String
    let lastName: String
    let imageData: String?
    let birthDay: Date

    init(
        id: UUID,
        firstName: String,
        lastName: String,
        imageData: String?,
        birthDay: Date
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.imageData = imageData
        self.birthDay = birthDay
    }

    func toEntity() -> UserEntity {
        return UserEntity(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            imageData: self.imageData,
            birthDay: self.birthDay,
        )
    }
}
