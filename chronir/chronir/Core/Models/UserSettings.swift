import Foundation
import Observation

@Observable
final class UserSettings {
    static let shared = UserSettings()

    private static let defaults = UserDefaults.standard

    var snoozeEnabled: Bool {
        didSet { Self.defaults.set(snoozeEnabled, forKey: "snoozeEnabled") }
    }

    var slideToStopEnabled: Bool {
        didSet { Self.defaults.set(slideToStopEnabled, forKey: "slideToStopEnabled") }
    }

    var selectedAlarmSound: String {
        didSet { Self.defaults.set(selectedAlarmSound, forKey: "selectedAlarmSound") }
    }

    var timezoneMode: TimezoneMode {
        didSet { Self.defaults.set(timezoneMode.rawValue, forKey: "timezoneMode") }
    }

    var hasCompletedOnboarding: Bool {
        didSet { Self.defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    private init() {
        Self.defaults.register(defaults: [
            "snoozeEnabled": true,
            "slideToStopEnabled": false,
            "selectedAlarmSound": "alarm",
            "timezoneMode": TimezoneMode.floating.rawValue,
            "hasCompletedOnboarding": false
        ])

        snoozeEnabled = Self.defaults.bool(forKey: "snoozeEnabled")
        slideToStopEnabled = Self.defaults.bool(forKey: "slideToStopEnabled")
        selectedAlarmSound = Self.defaults.string(forKey: "selectedAlarmSound") ?? "alarm"
        let raw = Self.defaults.string(forKey: "timezoneMode") ?? TimezoneMode.floating.rawValue
        timezoneMode = TimezoneMode(rawValue: raw) ?? .floating
        hasCompletedOnboarding = Self.defaults.bool(forKey: "hasCompletedOnboarding")
    }
}
