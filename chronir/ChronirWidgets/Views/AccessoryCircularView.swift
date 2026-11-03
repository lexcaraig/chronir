import SwiftUI
import WidgetKit

/// Lock screen circular widget: countdown ring scaled to the alarm's own cycle, with a days/hours/minutes value.
struct AccessoryCircularView: View {
    let alarm: WidgetAlarmData?
    /// The timeline entry's date. WidgetKit pre-renders entries, so wall-clock `now` is not the display time.
    let date: Date

    var body: some View {
        if let alarm {
            let remaining = max(alarm.nextFireDate.timeIntervalSince(date), 0)
            // Fills as the alarm approaches, over one cycle (a week, a month, a year).
            let progress = min(max(1.0 - remaining / alarm.cycleLength, 0), 1)

            Gauge(value: progress) {
                Image(systemName: "bell.fill")
            } currentValueLabel: {
                Text(Self.shortRemaining(remaining))
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.6)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(WidgetTokens.accent)
            .widgetAccentable()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(alarm.title), in \(Self.spokenRemaining(remaining))")
        } else {
            Gauge(value: 0) {
                Image(systemName: "bell.slash")
            } currentValueLabel: {
                Text("--")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("No upcoming alarms")
        }
    }

    /// "3d", "5h", "42m" — rounded up so 59 minutes never reads "0h".
    nonisolated static func shortRemaining(_ seconds: TimeInterval) -> String {
        let minutes = Int((seconds / 60).rounded(.up))
        if minutes >= 24 * 60 { return "\(minutes / (24 * 60))d" }
        if minutes >= 60 { return "\(minutes / 60)h" }
        return "\(max(minutes, 0))m"
    }

    /// Dates in `(start, end)` at which `shortRemaining` shows a new value, so the timeline can carry an
    /// entry for each change: hourly inside the last day, every minute inside the last hour (about 83
    /// entries at most). Entries cost no reload budget. The displayed value for `M` rounded-up minutes
    /// holds while the remaining time is in `((M-1)·60, M·60]` seconds, so it changes at whole minutes
    /// before the fire date.
    nonisolated static func valueChangeDates(fireDate: Date, after start: Date, before end: Date) -> [Date] {
        let firstMinute = max(Int(fireDate.timeIntervalSince(end) / 60), 0)
        let lastMinute = Int(fireDate.timeIntervalSince(start) / 60)
        guard firstMinute <= lastMinute else { return [] }
        return (firstMinute...lastMinute).reversed().compactMap { minutes in
            let seconds = TimeInterval(minutes * 60)
            guard shortRemaining(seconds) != shortRemaining(seconds + 60) else { return nil }
            let change = fireDate.addingTimeInterval(-seconds)
            return change > start && change < end ? change : nil
        }
    }

    static func spokenRemaining(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = seconds >= 86_400 ? [.day] : seconds >= 3_600 ? [.hour] : [.minute]
        return formatter.string(from: max(seconds, 60)) ?? ""
    }
}

#Preview("Circular", as: .accessoryCircular) {
    NextAlarmWidget()
} timeline: {
    NextAlarmEntry(date: .now, alarm: .preview)
    NextAlarmEntry(date: .now.addingTimeInterval(86_400 * 3 - 3_600 * 5), alarm: .preview)
    NextAlarmEntry(date: .now.addingTimeInterval(86_400 * 3 - 60 * 42), alarm: .preview)
}
