import Foundation
import FirebaseAuth

protocol AuthServiceProtocol: Sendable {
    func signIn(email: String, password: String) async throws -> UserProfile
    func signUp(email: String, password: String, displayName: String) async throws -> UserProfile
    func signOut() throws
    func currentUser() -> UserProfile?
    func deleteAccount() async throws
}

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    private init() {}

    func signIn(email: String, password: String) async throws -> UserProfile {
        // TODO: Implement in Sprint 3 - Firebase Auth
        fatalError("TODO: Implement signIn")
    }

    func signUp(email: String, password: String, displayName: String) async throws -> UserProfile {
        // TODO: Implement in Sprint 3
        fatalError("TODO: Implement signUp")
    }

    func signOut() throws {
        // TODO: Implement in Sprint 3
    }

    func currentUser() -> UserProfile? {
        // TODO: Implement in Sprint 3
        return nil
    }

    func deleteAccount() async throws {
        // TODO: Implement in Sprint 3
    }
}
