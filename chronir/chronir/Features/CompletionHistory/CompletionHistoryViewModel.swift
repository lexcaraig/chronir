import Foundation
import Observation
import SwiftData

@Observable
final class CompletionHistoryViewModel {
    var logs: [CompletionLog] = []
    var groupedLogs: [(date: String, logs: [CompletionLog])] = []
    var isLoading = false

    private let alarmID: UUID?

    init(alarmID: UUID? = nil) {
        self.alarmID = alarmID
    }

    /// Fetch logs directly from the provided context (must be the main context)
    /// to avoid SwiftData detached-object crashes from @ModelActor background contexts.
    @MainActor
    func loadLogs(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }

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

        let fetched = (try? context.fetch(descriptor)) ?? []
        logs = fetched
        groupedLogs = groupByDate(fetched)
    }

    private func groupByDate(_ logs: [CompletionLog]) -> [(date: String, logs: [CompletionLog])] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        var groups: [String: [CompletionLog]] = [:]
        var dateOrder: [String] = []

        for log in logs {
            let dateKey = formatter.string(from: log.completedAt)
            if groups[dateKey] == nil {
                dateOrder.append(dateKey)
            }
            groups[dateKey, default: []].append(log)
        }

        return dateOrder.map { key in
            (date: key, logs: groups[key] ?? [])
        }
    }
}
