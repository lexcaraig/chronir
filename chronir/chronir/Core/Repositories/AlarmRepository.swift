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

struct AlarmSummary: Sendable {
    let id: UUID
    let title: String
    let nextFireDate: Date
    let scheduleDisplayName: String
    let cycleType: CycleType
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

    func fetchEnabledSummaries() async throws -> [AlarmSummary] {
        // Use a fresh context to ensure we see the latest persisted data
        // (the actor's cached context may not reflect main context changes)
        let freshContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.isEnabled == true },
            sortBy: [SortDescriptor(\.nextFireDate)]
        )
        let alarms = try freshContext.fetch(descriptor)
        return alarms.map { alarm in
            AlarmSummary(
                id: alarm.id,
                title: alarm.title,
                nextFireDate: alarm.nextFireDate,
                scheduleDisplayName: alarm.schedule.displayName,
                cycleType: alarm.cycleType
            )
        }
    }

    func countActiveAlarms() async throws -> Int {
        let freshContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate<Alarm> { $0.isEnabled == true }
        )
        return try freshContext.fetchCount(descriptor)
    }

    func createAndSaveAlarm(
        title: String,
        cycleType: CycleType,
        schedule: Schedule,
        hour: Int,
        minute: Int,
        persistenceLevel: PersistenceLevel = .notificationOnly,
        preAlarmMinutes: Int = 0
    ) async throws -> UUID {
        let alarm = Alarm(
            title: title,
            cycleType: cycleType,
            timesOfDay: [TimeOfDay(hour: hour, minute: minute)],
            schedule: schedule,
            persistenceLevel: persistenceLevel,
            preAlarmMinutes: preAlarmMinutes
        )
        let calc = DateCalculator()
        alarm.nextFireDate = calc.calculateNextFireDate(for: alarm, from: Date())
        modelContext.insert(alarm)
        try modelContext.save()
        return alarm.id
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
