import AppIntents
import Foundation

// Compiled into BOTH the app and the widget extension.

/// Mirrors `AlarmCategory` raw values for App Intents (the widget extension can't import the app's model).
enum AlarmCategoryAppEnum: String, AppEnum {
    case home, health, finance, vehicle, work, personal, pets, subscriptions

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    static let caseDisplayRepresentations: [AlarmCategoryAppEnum: DisplayRepresentation] = [
        .home: "Home", .health: "Health", .finance: "Finance", .vehicle: "Vehicle",
        .work: "Work", .personal: "Personal", .pets: "Pets", .subscriptions: "Subscriptions"
    ]
}

/// Categories the active Focus shows (empty = no filter). Display-only: scheduling never reads this.
enum FocusFilterStore {
    static var defaults: UserDefaults? { UserDefaults(suiteName: "group.com.chronir.shared") }
    static let key = "focusFilterCategories"

    /// Comma-joined raw values, so SwiftUI can observe it with `@AppStorage`.
    static func parse(_ raw: String) -> Set<String> {
        Set(raw.split(separator: ",").map(String.init))
    }

    static var categories: Set<String> {
        parse(defaults?.string(forKey: key) ?? "")
    }
}
