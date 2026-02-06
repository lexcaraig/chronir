import Foundation

protocol GroupRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [AlarmGroup]
    func fetch(by id: UUID) async throws -> AlarmGroup?
    func save(_ group: AlarmGroup) async throws
    func delete(_ group: AlarmGroup) async throws
    func update(_ group: AlarmGroup) async throws
    func fetchGroups(for userID: String) async throws -> [AlarmGroup]
}

final class GroupRepository: GroupRepositoryProtocol {
    static let shared = GroupRepository()

    private init() {}

    func fetchAll() async throws -> [AlarmGroup] {
        // TODO: Implement in Sprint 4
        return []
    }

    func fetch(by id: UUID) async throws -> AlarmGroup? {
        // TODO: Implement in Sprint 4
        return nil
    }

    func save(_ group: AlarmGroup) async throws {
        // TODO: Implement in Sprint 4
    }

    func delete(_ group: AlarmGroup) async throws {
        // TODO: Implement in Sprint 4
    }

    func update(_ group: AlarmGroup) async throws {
        // TODO: Implement in Sprint 4
    }

    func fetchGroups(for userID: String) async throws -> [AlarmGroup] {
        // TODO: Implement in Sprint 4
        return []
    }
}
