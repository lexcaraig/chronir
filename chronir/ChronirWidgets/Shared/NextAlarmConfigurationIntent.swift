import AppIntents
import WidgetKit

/// Widget configuration: show the next alarm (default), a pinned alarm, or the next alarm in a category.
struct NextAlarmConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose Alarm"
    static let description = IntentDescription(
        "Show your next alarm, a specific alarm, or the next alarm in a category."
    )

    @Parameter(title: "Alarm")
    var alarm: AlarmEntity?

    @Parameter(title: "Category")
    var category: AlarmCategoryAppEnum?
}
