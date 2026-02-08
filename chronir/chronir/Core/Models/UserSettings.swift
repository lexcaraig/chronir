import Foundation
import Observation

@Observable
final class UserSettings {
    static let shared = UserSettings()

    var snoozeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "snoozeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "snoozeEnabled") }
    }

    var slideToStopEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "slideToStopEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "slideToStopEnabled") }
    }

    var selectedAlarmSound: String {
        get { UserDefaults.standard.string(forKey: "selectedAlarmSound") ?? "alarm" }
        set { UserDefaults.standard.set(newValue, forKey: "selectedAlarmSound") }
    }

    var timezoneMode: TimezoneMode {
        get {
            let raw = UserDefaults.standard.string(forKey: "timezoneMode") ?? TimezoneMode.floating.rawValue
            return TimezoneMode(rawValue: raw) ?? .floating
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "timezoneMode") }
    }

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    private init() {
        registerDefaults()
    }

    private func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            "snoozeEnabled": true,
            "slideToStopEnabled": false,
            "selectedAlarmSound": "alarm",
            "timezoneMode": TimezoneMode.floating.rawValue,
            "hasCompletedOnboarding": false
        ])
    }
}
