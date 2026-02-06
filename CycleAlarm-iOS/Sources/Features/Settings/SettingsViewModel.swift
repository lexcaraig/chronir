import Foundation
import Observation

@Observable
final class SettingsViewModel {
    // TODO: Implement in Sprint 3

    var userProfile: UserProfile?
    var isLoading: Bool = false
    var errorMessage: String?

    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol

    init(
        authService: AuthServiceProtocol = AuthService.shared,
        userRepository: UserRepositoryProtocol = UserRepository.shared
    ) {
        self.authService = authService
        self.userRepository = userRepository
    }

    func loadProfile() async {
        // TODO: Implement in Sprint 3
    }

    func signOut() {
        // TODO: Implement in Sprint 3
    }

    func deleteAccount() async {
        // TODO: Implement in Sprint 3
    }
}
