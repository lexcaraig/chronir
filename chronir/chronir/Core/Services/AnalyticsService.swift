import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

protocol AnalyticsServiceProtocol {
    func logEvent(_ name: String, parameters: [String: Any]?)
    func recordError(_ error: Error, context: String?)
    func setUserProperty(_ value: String?, forName name: String)
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    private init() {}

    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    func recordError(_ error: Error, context: String? = nil) {
        var userInfo: [String: Any] = [:]
        if let context {
            userInfo["context"] = context
        }
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}

enum AnalyticsEvent {
    static let alarmCreated = "alarm_created"
    static let alarmFired = "alarm_fired"
    static let alarmCompleted = "alarm_completed"
    static let alarmSnoozed = "alarm_snoozed"
    static let alarmSkipped = "alarm_skipped"
    static let alarmDeleted = "alarm_deleted"
    static let upgradePromptShown = "upgrade_prompt_shown"
    static let upgradeCompleted = "upgrade_completed"
    static let onboardingCompleted = "onboarding_completed"
}
