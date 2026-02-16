import Foundation
import StoreKit

@MainActor
enum AppReviewService {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let completionCount = "appReview_completionCount"
        static let lastPromptDate = "appReview_lastPromptDate"
        static let installDate = "appReview_installDate"
    }

    private static let requiredCompletions = 5
    private static let minDaysSinceInstall = 7
    private static let minDaysBetweenPrompts = 120

    /// Call after each alarm completion to track and potentially request a review.
    static func recordCompletion() {
        // Record install date on first completion
        if defaults.object(forKey: Keys.installDate) == nil {
            defaults.set(Date(), forKey: Keys.installDate)
        }

        let count = defaults.integer(forKey: Keys.completionCount) + 1
        defaults.set(count, forKey: Keys.completionCount)

        guard shouldRequestReview(completionCount: count) else { return }

        // Use a short delay so the firing view dismisses first
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            requestReview()
        }
    }

    private static func shouldRequestReview(completionCount: Int) -> Bool {
        guard completionCount >= requiredCompletions else { return false }

        // Only prompt on milestone completions to avoid every-time prompts
        let milestones = [5, 15, 30, 60, 100]
        guard milestones.contains(completionCount) else { return false }

        // Minimum days since install
        if let installDate = defaults.object(forKey: Keys.installDate) as? Date {
            let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
            guard daysSinceInstall >= minDaysSinceInstall else { return false }
        }

        // Minimum days since last prompt
        if let lastPrompt = defaults.object(forKey: Keys.lastPromptDate) as? Date {
            let daysSincePrompt = Calendar.current.dateComponents([.day], from: lastPrompt, to: Date()).day ?? 0
            guard daysSincePrompt >= minDaysBetweenPrompts else { return false }
        }

        return true
    }

    private static func requestReview() {
        defaults.set(Date(), forKey: Keys.lastPromptDate)

        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        #endif
    }
}
