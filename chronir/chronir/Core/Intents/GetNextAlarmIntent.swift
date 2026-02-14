import AppIntents
import Foundation

struct GetNextAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Alarm"
    static var description: IntentDescription = "Check your next upcoming alarm in Chronir"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let repo = AlarmRepository.shared else {
            throw AlarmIntentError.repositoryUnavailable
        }

        let summaries = try await repo.fetchEnabledSummaries()
        let upcoming = summaries
            .filter { $0.nextFireDate > Date() && $0.nextFireDate != .distantFuture }
            .sorted { $0.nextFireDate < $1.nextFireDate }

        guard let next = upcoming.first else {
            return .result(dialog: "You don't have any upcoming alarms.")
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let dateStr = formatter.string(from: next.nextFireDate)
        return .result(dialog: "Your next alarm is \"\(next.title)\" on \(dateStr).")
    }
}
