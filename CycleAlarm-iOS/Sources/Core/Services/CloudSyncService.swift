import Foundation

protocol CloudSyncServiceProtocol: Sendable {
    func syncAlarms() async throws
    func pushLocalChanges() async throws
    func pullRemoteChanges() async throws
    func resolveConflicts() async throws
}

final class CloudSyncService: CloudSyncServiceProtocol {
    static let shared = CloudSyncService()

    private init() {}

    func syncAlarms() async throws {
        // TODO: Implement in Sprint 4 - Firebase Firestore sync
    }

    func pushLocalChanges() async throws {
        // TODO: Implement in Sprint 4
    }

    func pullRemoteChanges() async throws {
        // TODO: Implement in Sprint 4
    }

    func resolveConflicts() async throws {
        // TODO: Implement in Sprint 4
    }
}
