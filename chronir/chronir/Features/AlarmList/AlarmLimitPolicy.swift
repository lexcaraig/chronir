import Foundation

/// Which alarms the Free-tier limit turns off, and which ones it may turn back on after an upgrade.
/// Only alarms the limit itself disabled are restored; alarms the user turned off stay off (BUG-06).
enum AlarmLimitPolicy {
    /// IDs of alarms disabled by the limit, so an upgrade can restore exactly those.
    private static let storeKey = "limitDisabledAlarmIDs"

    /// Enabled alarms beyond `limit`, newest first to go; the oldest `limit` stay on.
    static func alarmsToDisable(enabled: [Alarm], limit: Int) -> [Alarm] {
        guard enabled.count > limit else { return [] }
        return Array(enabled.sorted { $0.createdAt < $1.createdAt }.dropFirst(limit))
    }

    /// Disabled alarms the limit turned off. Alarms the user turned off are not in `limitDisabled`.
    static func alarmsToRestore(disabled: [Alarm], limitDisabled: Set<UUID>) -> [Alarm] {
        disabled.filter { limitDisabled.contains($0.id) }
    }

    static func load(from defaults: UserDefaults = .standard) -> Set<UUID> {
        Set((defaults.stringArray(forKey: storeKey) ?? []).compactMap(UUID.init(uuidString:)))
    }

    static func save(_ ids: Set<UUID>, to defaults: UserDefaults = .standard) {
        if ids.isEmpty {
            defaults.removeObject(forKey: storeKey)
        } else {
            defaults.set(ids.map(\.uuidString), forKey: storeKey)
        }
    }
}
