//
//  OnboardingItem.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import Foundation

struct OnboardingItem: Codable {
    let title: String
    let description: String
    let image: String

    init(title: String, description: String, image: String) {
        self.title = title
        self.description = description
        self.image = image
    }
}
