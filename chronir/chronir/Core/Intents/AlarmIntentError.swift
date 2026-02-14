import Foundation

enum AlarmIntentError: Error, CustomLocalizedStringResourceConvertible {
    case freeTierLimitReached
    case repositoryUnavailable
    case schedulingFailed
    case invalidInput

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .freeTierLimitReached:
            return "You've reached the free tier limit of 2 alarms. Upgrade to Plus for unlimited alarms."
        case .repositoryUnavailable:
            return "Chronir isn't ready yet. Please open the app first."
        case .schedulingFailed:
            return "Failed to schedule the alarm. Please try again."
        case .invalidInput:
            return "The alarm name is invalid. Please provide a non-empty name."
        }
    }
}
