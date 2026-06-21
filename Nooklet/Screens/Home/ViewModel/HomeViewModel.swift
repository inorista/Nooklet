//
//  HomeViewModel.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//

import Foundation
import RealmSwift
import SwiftUI
import UIKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var greeting: String = "Good morning,"
    @Published var user: User?

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

    public func loadUserData() async {
        do {
            self.user = try RealmService.shared.getUser()
        } catch {
            print("Error loading user from Realm: \(error)")
        }
    }
}
