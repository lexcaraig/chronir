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

    var wallpaperImageName: String? {
        didSet { Self.defaults.set(wallpaperImageName, forKey: "wallpaperImageName") }
    }

    var wallpaperScale: Double {
        didSet { Self.defaults.set(wallpaperScale, forKey: "wallpaperScale") }
    }

    var wallpaperOffsetX: Double {
        didSet { Self.defaults.set(wallpaperOffsetX, forKey: "wallpaperOffsetX") }
    }

    var wallpaperOffsetY: Double {
        didSet { Self.defaults.set(wallpaperOffsetY, forKey: "wallpaperOffsetY") }
    }

    var wallpaperIsLight: Bool {
        didSet { Self.defaults.set(wallpaperIsLight, forKey: "wallpaperIsLight") }
    }

    var groupAlarmsByCategory: Bool {
        didSet { Self.defaults.set(groupAlarmsByCategory, forKey: "groupAlarmsByCategory") }
    }

    var hapticsEnabled: Bool {
        didSet { Self.defaults.set(hapticsEnabled, forKey: "hapticsEnabled") }
    }

    private init() {
        Self.defaults.register(defaults: [
            "snoozeEnabled": true,
            "slideToStopEnabled": false,
            "selectedAlarmSound": "alarm",
            "timezoneMode": TimezoneMode.floating.rawValue,
            "hasCompletedOnboarding": false,
            "wallpaperScale": 1.0,
            "groupAlarmsByCategory": false,
            "hapticsEnabled": true
        ])

        snoozeEnabled = Self.defaults.bool(forKey: "snoozeEnabled")
        slideToStopEnabled = Self.defaults.bool(forKey: "slideToStopEnabled")
        selectedAlarmSound = Self.defaults.string(forKey: "selectedAlarmSound") ?? "alarm"
        let raw = Self.defaults.string(forKey: "timezoneMode") ?? TimezoneMode.floating.rawValue
        timezoneMode = TimezoneMode(rawValue: raw) ?? .floating
        hasCompletedOnboarding = Self.defaults.bool(forKey: "hasCompletedOnboarding")
        wallpaperImageName = Self.defaults.string(forKey: "wallpaperImageName")
        let savedScale = Self.defaults.double(forKey: "wallpaperScale")
        wallpaperScale = savedScale == 0 ? 1.0 : savedScale
        wallpaperOffsetX = Self.defaults.double(forKey: "wallpaperOffsetX")
        wallpaperOffsetY = Self.defaults.double(forKey: "wallpaperOffsetY")
        wallpaperIsLight = Self.defaults.bool(forKey: "wallpaperIsLight")
        groupAlarmsByCategory = Self.defaults.bool(forKey: "groupAlarmsByCategory")
        hapticsEnabled = Self.defaults.bool(forKey: "hapticsEnabled")
    }
}
