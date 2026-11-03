import Foundation

/// Reads alarm data from the shared App Group container.
/// Used by widget extension timeline providers.
enum WidgetDataReader {
    private static let appGroupID = "group.com.chronir.shared"
    private static let fileName = "widget-data.json"

    static func load() -> WidgetDataPayload? {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        let fileURL = containerURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WidgetDataPayload.self, from: data)
    }

    static func loadAlarms() -> [WidgetAlarmData] {
        let payload = load()
        let now = Date()
        return (payload?.alarms ?? [])
            .filter { $0.nextFireDate > now || $0.nextFireDate == .distantFuture }
            .sorted { $0.nextFireDate < $1.nextFireDate }
    }

    static func nextAlarm() -> WidgetAlarmData? {
        loadAlarms().first { $0.nextFireDate != .distantFuture }
    }

    /// Resolves a widget configuration. `pinnedMissing` is true when the pinned alarm was deleted or
    /// disabled, in which case the next alarm is shown instead.
    static func alarm(for config: NextAlarmConfigurationIntent) -> (alarm: WidgetAlarmData?, pinnedMissing: Bool) {
        let scheduled = loadAlarms().filter { $0.nextFireDate != .distantFuture }
        if let pinned = config.alarm {
            if let match = scheduled.first(where: { $0.id == pinned.id }) { return (match, false) }
            return (scheduled.first, true)
        }
        if let category = config.category {
            return (scheduled.first { $0.categoryName == category.rawValue }, false)
        }
        return (scheduled.first, false)
    }
}
