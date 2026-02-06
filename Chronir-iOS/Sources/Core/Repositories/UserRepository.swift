import Foundation

protocol UserRepositoryProtocol: Sendable {
    func fetchProfile(for userID: String) async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
    func updateProfile(_ profile: UserProfile) async throws
    func deleteProfile(for userID: String) async throws
}

final class UserRepository: UserRepositoryProtocol {
    static let shared = UserRepository()

    private init() {}

    func fetchProfile(for userID: String) async throws -> UserProfile? {
        // TODO: Implement in Sprint 3
        return nil
    }

    func saveProfile(_ profile: UserProfile) async throws {
        // TODO: Implement in Sprint 3
    }

    func updateProfile(_ profile: UserProfile) async throws {
        // TODO: Implement in Sprint 3
    }

    func deleteProfile(for userID: String) async throws {
        // TODO: Implement in Sprint 3
    }
}
