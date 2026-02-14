import AppIntents

struct ChronirShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateAlarmIntent(),
            phrases: [
                "Create an alarm in \(.applicationName)",
                "Add an alarm in \(.applicationName)",
                "New alarm in \(.applicationName)"
            ],
            shortTitle: "Create Alarm",
            systemImageName: "alarm.fill"
        )
        AppShortcut(
            intent: GetNextAlarmIntent(),
            phrases: [
                "What's my next alarm in \(.applicationName)",
                "Next alarm in \(.applicationName)",
                "When is my next alarm in \(.applicationName)"
            ],
            shortTitle: "Next Alarm",
            systemImageName: "clock"
        )
        AppShortcut(
            intent: ListAlarmsIntent(),
            phrases: [
                "List my alarms in \(.applicationName)",
                "Show my alarms in \(.applicationName)",
                "What alarms do I have in \(.applicationName)"
            ],
            shortTitle: "List Alarms",
            systemImageName: "list.bullet"
        )
    }
}
