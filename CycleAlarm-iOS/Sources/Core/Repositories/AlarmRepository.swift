import Foundation

protocol AlarmRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Alarm]
    func fetch(by id: UUID) async throws -> Alarm?
    func save(_ alarm: Alarm) async throws
    func delete(_ alarm: Alarm) async throws
    func update(_ alarm: Alarm) async throws
    func fetchEnabled() async throws -> [Alarm]
}

final class AlarmRepository: AlarmRepositoryProtocol {
    static let shared = AlarmRepository()

    private init() {}

    func fetchAll() async throws -> [Alarm] {
        // TODO: Implement in Sprint 1 - SwiftData queries
        return []
    }

    func fetch(by id: UUID) async throws -> Alarm? {
        // TODO: Implement in Sprint 1
        return nil
    }

    func save(_ alarm: Alarm) async throws {
        // TODO: Implement in Sprint 1
    }

    func delete(_ alarm: Alarm) async throws {
        // TODO: Implement in Sprint 1
    }

    func update(_ alarm: Alarm) async throws {
        // TODO: Implement in Sprint 1
    }

    func fetchEnabled() async throws -> [Alarm] {
        // TODO: Implement in Sprint 1
        return []
    }
}
