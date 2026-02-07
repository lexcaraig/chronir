import Foundation

protocol StorageServiceProtocol: Sendable {
    func uploadData(_ data: Data, path: String) async throws -> URL
    func downloadData(from path: String) async throws -> Data
    func deleteData(at path: String) async throws
}

final class StorageService: StorageServiceProtocol {
    static let shared = StorageService()

    private init() {}

    func uploadData(_ data: Data, path: String) async throws -> URL {
        // TODO: Implement in Sprint 4 - Firebase Storage
        fatalError("TODO: Implement uploadData")
    }

    func downloadData(from path: String) async throws -> Data {
        // TODO: Implement in Sprint 4
        fatalError("TODO: Implement downloadData")
    }

    func deleteData(at path: String) async throws {
        // TODO: Implement in Sprint 4
    }
}
