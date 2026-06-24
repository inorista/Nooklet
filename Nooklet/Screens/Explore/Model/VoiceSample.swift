//
//  VoiceSample.swift
//  Nooklet
//
//  Created by Tu on 24/6/26.
//

import Foundation
import SwiftUI

struct VoiceSample: Identifiable, Equatable {
    let id: UUID
    let content: String
    let fileName: String
    let author: String
    let avatar: String

    init(
        id: UUID = UUID(),
        content: String,
        fileName: String,
        author: String,
        avatar: String
    ) {
        self.id = id
        self.content = content
        self.fileName = fileName
        self.author = author
        self.avatar = avatar
    }

    static func == (lhs: VoiceSample, rhs: VoiceSample) -> Bool {
        [lhs.content, lhs.fileName, lhs.author, lhs.avatar] == [
            rhs.content, rhs.fileName, rhs.author, rhs.avatar,
        ]
    }

}
