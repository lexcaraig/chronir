import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Next Alarm control

struct NextAlarmControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.chronir.ios.control.nextAlarm",
            provider: NextAlarmControlProvider()
        ) { alarm in
            ControlWidgetButton(action: OpenChronirLinkIntent(path: alarm.map { "alarm/\($0.id.uuidString)" } ?? "")) {
                if let alarm {
                    Label {
                        Text(alarm.title)
                        Text(alarm.nextFireDate.formatted(date: .abbreviated, time: .shortened))
                    } icon: {
                        Image(systemName: "alarm")
                    }
                } else {
                    Label("No upcoming alarms", systemImage: "alarm")
                }
            }
        }
        .displayName("Next Alarm")
        .description("Shows your next Chronir alarm and opens it.")
    }
}

struct NextAlarmControlProvider: ControlValueProvider {
    /// Shown in the Controls gallery, so it demonstrates a real alarm rather than the empty state.
    var previewValue: WidgetAlarmData? { .preview }

    func currentValue() async throws -> WidgetAlarmData? {
        WidgetDataReader.nextAlarm()
    }
}

// MARK: - New Alarm control

struct NewAlarmControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.chronir.ios.control.newAlarm") {
            ControlWidgetButton(action: OpenChronirLinkIntent(path: "new")) {
                Label("New Alarm", systemImage: "plus.circle")
            }
        }
        .displayName("New Alarm")
        .description("Opens Chronir to create an alarm.")
    }
}

// MARK: - Intent

/// Opens a `chronir://` deep link; the app validates the payload in `onOpenURL` (SEC-05).
struct OpenChronirLinkIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Chronir"
    static let isDiscoverable = false

    @Parameter(title: "Path")
    var path: String

    init() {}

    init(path: String) {
        self.path = path
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        let url = URL(string: "chronir://\(path)") ?? URL(string: "chronir://")!
        return .result(opensIntent: OpenURLIntent(url))
    }
}
