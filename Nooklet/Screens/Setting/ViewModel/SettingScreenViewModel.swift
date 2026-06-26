import Foundation
import Combine

class SettingScreenViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    init() {
        loadUser()
    }

    func loadUser() {
        isLoading = true
        do {
            if let entity = try RealmService.shared.getUser() {
                self.currentUser = entity.toModel()
            }
        } catch {
            self.errorMessage = "Failed to load user: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func updateProfile(firstName: String, lastName: String, birthDay: Date, imageData: String? = nil) {
        guard var user = currentUser else { return }

        // Update local state
        let updatedUser = User(
            id: user.id,
            firstName: firstName,
            lastName: lastName,
            imageData: imageData ?? user.imageData,
            birthDay: birthDay
        )

        do {
            try RealmService.shared.updateUser(updatedUser)
            self.currentUser = updatedUser
        } catch {
            self.errorMessage = "Failed to update user profile: \(error.localizedDescription)"
        }
    }
}
