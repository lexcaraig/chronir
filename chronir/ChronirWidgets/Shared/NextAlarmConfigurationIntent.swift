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
    var category: WidgetCategory?
}

/// Mirrors the app's `AlarmCategory` raw values (the widget extension can't import the app).
enum WidgetCategory: String, AppEnum {
    case home, health, finance, vehicle, work, personal, pets, subscriptions

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    static let caseDisplayRepresentations: [WidgetCategory: DisplayRepresentation] = [
        .home: "Home", .health: "Health", .finance: "Finance", .vehicle: "Vehicle",
        .work: "Work", .personal: "Personal", .pets: "Pets", .subscriptions: "Subscriptions"
    ]
}
