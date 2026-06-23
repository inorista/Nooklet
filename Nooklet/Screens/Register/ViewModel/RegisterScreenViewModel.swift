//
//  RegisterScreenViewModel.swift
//  Nooklet
//
//  Created by Tu on 18/6/26.
//
import Foundation
import RealmSwift
import SwiftUI

@MainActor
class RegisterScreenViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthday: Date = Date()
    @Published var selectedAvatar: String = "Avatar1"
    @Published var isAvatarSheetPresented: Bool = false

    let avatars: [String] = (1...15).map { "Avatar\($0)" }

    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func selectAvatar(_ avatar: String) {
        selectedAvatar = avatar
        isAvatarSheetPresented = false
    }

    func onRegister() async {
        let user: User = User(
            id: UUID(),
            firstName: firstName,
            lastName: lastName,
            imageData: selectedAvatar,
            birthDay: birthday
        )
        let userEntity: UserEntity = user.toEntity()

        do {
            try RealmService.shared.saveUser(userEntity)
        } catch {
            print("Error saving user to Realm: \(error)")
        }

        withAnimation(.easeInOut(duration: 0.5)) {
            UserDefaultsService.shared.hasSeenOnboarding = true
        }
    }
}
