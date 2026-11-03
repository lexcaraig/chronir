import AppIntents
import WidgetKit

/// Focus filter: while a Focus is on, the alarm list and widgets show only the chosen categories.
/// Alarms in hidden categories still fire (FB-01) — this only changes what's displayed.
struct ChronirFocusFilter: SetFocusFilterIntent {
    static let title: LocalizedStringResource = "Show Alarm Categories"
    static let description: IntentDescription? = "Only show alarms in these categories while this Focus is on."

    @Parameter(title: "Categories")
    var categories: [AlarmCategoryAppEnum]?

    var displayRepresentation: DisplayRepresentation {
        let names = (categories ?? []).map { $0.rawValue.capitalized }
        return DisplayRepresentation(title: names.isEmpty ? "All categories" : "\(names.joined(separator: ", "))")
    }

    // The system calls this with default (nil) parameters when the Focus turns off, clearing the filter.
    func perform() async throws -> some IntentResult {
        let raw = (categories ?? []).map(\.rawValue).joined(separator: ",")
        FocusFilterStore.defaults?.set(raw, forKey: FocusFilterStore.key)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
