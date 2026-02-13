import Foundation
import SwiftData

protocol AlarmRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Alarm]
    func fetch(by id: UUID) async throws -> Alarm?
    func save(_ alarm: Alarm) async throws
    func delete(_ alarm: Alarm) async throws
    func update(_ alarm: Alarm) async throws
    func fetchEnabled() async throws -> [Alarm]
    func saveCompletionLog(_ log: CompletionLog) async throws
    func fetchCompletionLogs(for alarmID: UUID?) async throws -> [CompletionLog]
}

@ModelActor
actor AlarmRepository: AlarmRepositoryProtocol {
    static var shared: AlarmRepository!

    static func configure(with container: ModelContainer) {
        shared = AlarmRepository(modelContainer: container)
    }

    func fetchAll() async throws -> [Alarm] {
        let descriptor = FetchDescriptor<Alarm>(
            sortBy: [SortDescriptor(\.nextFireDate)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetch(by id: UUID) async throws -> Alarm? {
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func save(_ alarm: Alarm) async throws {
        modelContext.insert(alarm)
        try modelContext.save()
    }

    func delete(_ alarm: Alarm) async throws {
        modelContext.delete(alarm)
        try modelContext.save()
    }

    func update(_ alarm: Alarm) async throws {
        // SwiftData auto-tracks changes on managed objects
        try modelContext.save()
    }

    func fetchEnabled() async throws -> [Alarm] {
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.isEnabled == true },
            sortBy: [SortDescriptor(\.nextFireDate)]
        )
        return try modelContext.fetch(descriptor)
    }

    func saveCompletionLog(_ log: CompletionLog) async throws {
        // Link to alarm if possible
        if log.alarm == nil {
            let targetID = log.alarmID
            let descriptor = FetchDescriptor<Alarm>(
                predicate: #Predicate<Alarm> { $0.id == targetID }
            )
            if let alarm = try? modelContext.fetch(descriptor).first {
                log.alarm = alarm
            }
        }
        modelContext.insert(log)
        try modelContext.save()
    }

    func fetchCompletionLogs(for alarmID: UUID?) async throws -> [CompletionLog] {
        let descriptor: FetchDescriptor<CompletionLog>
        if let alarmID {
            descriptor = FetchDescriptor<CompletionLog>(
                predicate: #Predicate<CompletionLog> { $0.alarmID == alarmID },
                sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<CompletionLog>(
                sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
            )
        }
        return try modelContext.fetch(descriptor)
    }
}
