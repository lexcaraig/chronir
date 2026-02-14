import AppIntents
import Foundation

struct ListAlarmsIntent: AppIntent {
    static var title: LocalizedStringResource = "List Alarms"
    static var description: IntentDescription = "List your active alarms in Chronir"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let repo = AlarmRepository.shared else {
            throw AlarmIntentError.repositoryUnavailable
        }

        let summaries = try await repo.fetchEnabledSummaries()
        let upcoming = summaries
            .filter { $0.nextFireDate != .distantFuture }
            .sorted { $0.nextFireDate < $1.nextFireDate }
            .prefix(5)

        guard !upcoming.isEmpty else {
            return .result(dialog: "You don't have any active alarms.")
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        let lines = upcoming.map { summary in
            "\(summary.title) — \(formatter.string(from: summary.nextFireDate))"
        }
        let list = lines.joined(separator: "\n")

        return .result(dialog: "Your alarms:\n\(list)")
    }
}
