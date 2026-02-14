import Foundation

protocol StorageServiceProtocol: Sendable {
    func uploadData(_ data: Data, path: String) async throws -> URL
    func downloadData(from path: String) async throws -> Data
    func deleteData(at path: String) async throws
}

enum StorageError: LocalizedError {
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Cloud storage is not yet available."
        }
    }
}

final class StorageService: StorageServiceProtocol {
    static let shared = StorageService()

    private init() {}

    func uploadData(_ data: Data, path: String) async throws -> URL {
        throw StorageError.notImplemented
    }

    func downloadData(from path: String) async throws -> Data {
        throw StorageError.notImplemented
    }

    func deleteData(at path: String) async throws {
        throw StorageError.notImplemented
    }
}
