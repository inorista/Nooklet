//
//  User.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import Foundation
import SwiftData

@Model
class User {
    var id: UUID = UUID()
    var firstName: String
    var lastName: String
    var imageData: String?
    init(
        id: UUID,
        firstName: String,
        lastName: String,
        imageData: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.imageData = imageData
    }
}
