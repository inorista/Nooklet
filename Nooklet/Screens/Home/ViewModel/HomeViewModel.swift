//
//  HomeViewModel.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var greeting: String = "Good morning,"

    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<5:
            return "Good night,"
        case 5..<12:
            return "Good morning,"
        case 12..<18:
            return "Good afternoon,"
        default:
            return "Good morning,"
        }
    }

    init() {
        self.greeting = getGreeting()
    }
}
