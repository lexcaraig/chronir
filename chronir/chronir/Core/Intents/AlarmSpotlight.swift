import AppIntents
import CoreSpotlight
import Foundation

// App-only: Spotlight indexing + the open action Spotlight runs when a result is tapped.

extension AlarmEntity: IndexedEntity {}

struct OpenAlarmIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Alarm"

    @Parameter(title: "Alarm")
    var target: AlarmEntity

    init() {}

    func perform() async throws -> some IntentResult & OpensIntent {
        // Deep link rather than an in-process notification: onOpenURL is delivered on cold launch too.
        guard let url = URL(string: "chronir://alarm/\(target.id.uuidString)") else { throw AlarmIntentError.alarmNotFound }
        return .result(opensIntent: OpenURLIntent(url))
    }
}

enum AlarmSpotlightIndex {
    /// Replaces the on-device index with the given alarms so deleted or disabled ones drop out.
    static func replace(with entities: [AlarmEntity]) async {
        let index = CSSearchableIndex.default()
        do {
            try await index.deleteAppEntities(ofType: AlarmEntity.self)
            try await index.indexAppEntities(entities)
        } catch {
            AnalyticsService.shared.recordError(error, context: "spotlight_index")
        }
    }
}
