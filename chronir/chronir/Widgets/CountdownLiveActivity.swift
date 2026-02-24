import Foundation

#if canImport(ActivityKit)
import ActivityKit

/// Attributes for the countdown Live Activity.
/// The widget extension has its own copy in ChronirWidgets/Views/CountdownLiveActivityView.swift.
struct AlarmCountdownAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var alarmTitle: String
        var fireDate: Date
    }

    var alarmID: String
    var cycleType: String
}
#endif
