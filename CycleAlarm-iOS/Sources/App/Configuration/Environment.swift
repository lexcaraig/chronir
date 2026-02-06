import Foundation

enum AppEnvironment: String, CaseIterable {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development:
            return "https://dev-api.cyclealarm.app"
        case .staging:
            return "https://staging-api.cyclealarm.app"
        case .production:
            return "https://api.cyclealarm.app"
        }
    }

    var firebaseConfigFileName: String {
        switch self {
        case .development:
            return "GoogleService-Info-Dev"
        case .staging:
            return "GoogleService-Info-Staging"
        case .production:
            return "GoogleService-Info"
        }
    }

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}
