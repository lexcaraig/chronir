import Foundation
import WidgetKit

final class WidgetDataService: Sendable {
    static let shared = WidgetDataService()

    private static let appGroupID = "group.com.chronir.shared"
    private static let fileName = "widget-data.json"

    private init() {}

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    static var dataFileURL: URL? {
        sharedContainerURL?.appendingPathComponent(fileName)
    }

    /// Fetches enabled alarms from the repository, writes JSON to the shared container,
    /// and reloads all widget timelines.
    func refresh() async {
        guard let repo = AlarmRepository.shared else { return }
        do {
            let summaries = try await repo.fetchEnabledSummaries()
            let widgetAlarms = summaries.map { summary in
                WidgetAlarmData(
                    id: summary.id,
                    title: summary.title,
                    nextFireDate: summary.nextFireDate,
                    scheduleDisplayName: summary.scheduleDisplayName,
                    cycleType: summary.cycleType.rawValue,
                    categoryName: nil,
                    categoryIconName: nil,
                    colorTag: nil
                )
            }
            let payload = WidgetDataPayload(alarms: widgetAlarms, lastUpdated: Date())

            guard let fileURL = Self.dataFileURL else { return }
            let data = try JSONEncoder().encode(payload)
            try data.write(to: fileURL, options: .atomic)

            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            // Non-critical — widget just shows stale data
        }
    }

    /// Extended version that includes category data from full alarm models.
    /// Call this when you have access to full Alarm objects.
    func refresh(with alarms: [WidgetAlarmData]) {
        let payload = WidgetDataPayload(alarms: alarms, lastUpdated: Date())

        guard let fileURL = Self.dataFileURL else { return }
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: fileURL, options: .atomic)

        WidgetCenter.shared.reloadAllTimelines()
    }
}
