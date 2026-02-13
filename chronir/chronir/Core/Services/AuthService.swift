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

    // TODO: Implement Firebase Auth when cloud backup is built (Sprint 10+)

    func signIn(email: String, password: String) async throws -> UserProfile {
        throw AuthError.notImplemented
    }

    func signUp(email: String, password: String, displayName: String) async throws -> UserProfile {
        throw AuthError.notImplemented
    }

    func signOut() throws {
        throw AuthError.notImplemented
    }

    func currentUser() -> UserProfile? {
        nil
    }

    func deleteAccount() async throws {
        throw AuthError.notImplemented
    }

    enum AuthError: LocalizedError {
        case notImplemented

        var errorDescription: String? {
            "Account features are not yet available."
        }
    }
}
