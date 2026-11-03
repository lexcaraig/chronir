import Foundation

/// Single source of truth for what Chronir Plus includes. Every entry is built and gated in code:
/// - `unlimitedAlarms`: `SubscriptionTier.alarmLimit`
/// - `customSnooze`: `AlarmFiringView` custom snooze picker
/// - `preAlarm`: `AlarmCreationForm` pre-alarm offsets (`requiresPlus`)
/// - `photos`: `Alarm` photo attachment, `AlarmDetailView`
/// - `notes`: `AlarmCreationForm` note field
/// - `sounds`: `AlarmSoundService.SoundOption.requiresPlus`
/// - `history`: `CompletionHistoryView`, `StreakCalculator`
/// - `cloudBackup`: `CloudSyncService` + `AccountView`
///
/// The paywall, Subscription screen, Backup & Sync page, and Completion History upsell all render from
/// this list so they can't drift. Never add a case for a feature that isn't shipped (App Review 2.3).
enum PlusFeature: String, CaseIterable, Identifiable {
    case unlimitedAlarms
    case preAlarm
    case cloudBackup
    case history
    case customSnooze
    case photos
    case notes
    case sounds

    var id: String { rawValue }

    var title: String {
        switch self {
        case .unlimitedAlarms: return "Unlimited alarms"
        case .preAlarm: return "Pre-alarm warnings"
        case .cloudBackup: return "Cloud backup & sync"
        case .history: return "Completion history & streaks"
        case .customSnooze: return "Custom snooze intervals"
        case .photos: return "Photo attachments"
        case .notes: return "Notes on alarms"
        case .sounds: return "More alarm sounds"
        }
    }

    /// Short label for the plan comparison table.
    var shortTitle: String {
        switch self {
        case .unlimitedAlarms: return "Alarms"
        case .preAlarm: return "Pre-alarm warnings"
        case .cloudBackup: return "Cloud backup"
        case .history: return "History & streaks"
        case .customSnooze: return "Custom snooze"
        case .photos: return "Photos"
        case .notes: return "Notes"
        case .sounds: return "Alarm sounds"
        }
    }

    var benefit: String {
        switch self {
        case .unlimitedAlarms: return "Track every bill, refill, and renewal."
        case .preAlarm: return "Get a heads-up days before it's due."
        case .cloudBackup: return "Your alarms follow you to a new iPhone."
        case .history: return "See every completion and keep your streak."
        case .customSnooze: return "Snooze for exactly as long as you need."
        case .photos: return "Attach a photo of the bill or label."
        case .notes: return "Keep account numbers and details with the alarm."
        case .sounds: return "\(AlarmSoundService.allSounds.count) sounds to choose from."
        }
    }

    var iconName: String {
        switch self {
        case .unlimitedAlarms: return "infinity"
        case .preAlarm: return "bell.and.waves.left.and.right"
        case .cloudBackup: return "icloud"
        case .history: return "chart.bar"
        case .customSnooze: return "clock.badge.checkmark"
        case .photos: return "photo"
        case .notes: return "note.text"
        case .sounds: return "speaker.wave.2"
        }
    }

    /// What the Free tier gets, or nil when the feature is Plus-only.
    var freeValue: String? {
        switch self {
        case .unlimitedAlarms: return SubscriptionTier.free.alarmLimit.map(String.init)
        case .sounds: return "\(AlarmSoundService.freeSounds.count)"
        default: return nil
        }
    }

    /// What Plus gets, or nil when it's simply "included".
    var plusValue: String? {
        switch self {
        case .unlimitedAlarms: return "Unlimited"
        case .sounds: return "\(AlarmSoundService.allSounds.count)"
        default: return nil
        }
    }

    /// All features, with `highlight` (the feature the user just tapped) moved to the top.
    static func ordered(highlighting highlight: PlusFeature?) -> [PlusFeature] {
        guard let highlight else { return allCases }
        return [highlight] + allCases.filter { $0 != highlight }
    }
}

/// Annual-vs-monthly math for the plan picker, from real StoreKit prices.
enum PlanPricing {
    /// Annual price spread over 12 months.
    static func monthlyEquivalent(annual: Decimal) -> Decimal {
        annual / 12
    }

    /// Whole-percent saving of annual vs. 12 x monthly, or nil when there is no saving.
    static func savingsPercent(monthly: Decimal, annual: Decimal) -> Int? {
        let yearOfMonthly = monthly * 12
        guard yearOfMonthly > 0, annual < yearOfMonthly else { return nil }
        let ratio = NSDecimalNumber(decimal: (yearOfMonthly - annual) / yearOfMonthly).doubleValue
        let percent = Int((ratio * 100).rounded(.down))
        return percent > 0 ? percent : nil
    }
}
