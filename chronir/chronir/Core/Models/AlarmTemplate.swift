import Foundation

struct AlarmTemplate: Identifiable {
    let id: String
    let title: String
    let category: AlarmCategory
    let cycleType: CycleType
    let repeatInterval: Int
    let daysOfMonth: Set<Int>
    let suggestedNote: String
    let iconName: String

    var intervalDescription: String {
        switch (cycleType, repeatInterval) {
        case (.monthlyDate, 1): return "Monthly"
        case (.monthlyDate, let n): return "Every \(n) months"
        case (.annual, 1): return "Annually"
        case (.annual, let n): return "Every \(n) years"
        case (.customDays, let n) where n % 30 == 0: return "Every \(n / 30) months"
        case (.customDays, let n) where n % 7 == 0: return "Every \(n / 7) weeks"
        case (.customDays, let n): return "Every \(n) days"
        default: return cycleType.displayName
        }
    }
}

// MARK: - Template Library

extension AlarmTemplate {
    static let all: [AlarmTemplate] = home + auto + health + finance

    static func forCategory(_ category: AlarmCategory) -> [AlarmTemplate] {
        all.filter { $0.category == category }
    }

    static let templateCategories: [AlarmCategory] = [.home, .vehicle, .health, .finance]

    // MARK: - Home

    static let home: [AlarmTemplate] = [
        AlarmTemplate(
            id: "home-hvac-filter",
            title: "Replace HVAC Filter",
            category: .home,
            cycleType: .monthlyDate,
            repeatInterval: 3,
            daysOfMonth: [1],
            suggestedNote: "Check filter size before buying. Standard sizes: 16x20x1, 20x25x1.",
            iconName: "fan.fill"
        ),
        AlarmTemplate(
            id: "home-smoke-detector",
            title: "Test Smoke Detectors",
            category: .home,
            cycleType: .monthlyDate,
            repeatInterval: 6,
            daysOfMonth: [1],
            suggestedNote: "Press test button on each detector. Replace batteries annually.",
            iconName: "sensor.fill"
        ),
        AlarmTemplate(
            id: "home-water-heater",
            title: "Flush Water Heater",
            category: .home,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Drain sediment from tank. Shut off power/gas first.",
            iconName: "drop.fill"
        ),
        AlarmTemplate(
            id: "home-gutter",
            title: "Clean Gutters",
            category: .home,
            cycleType: .monthlyDate,
            repeatInterval: 6,
            daysOfMonth: [1],
            suggestedNote: "Spring and fall cleaning. Check downspouts for clogs.",
            iconName: "house.fill"
        ),
        AlarmTemplate(
            id: "home-deep-clean",
            title: "Deep Clean",
            category: .home,
            cycleType: .monthlyDate,
            repeatInterval: 1,
            daysOfMonth: [1],
            suggestedNote: "Baseboards, windows, appliances, behind furniture.",
            iconName: "sparkles"
        ),
    ]

    // MARK: - Auto

    static let auto: [AlarmTemplate] = [
        AlarmTemplate(
            id: "auto-oil-change",
            title: "Oil Change",
            category: .vehicle,
            cycleType: .monthlyDate,
            repeatInterval: 6,
            daysOfMonth: [1],
            suggestedNote: "Check oil type in owner's manual. Note mileage.",
            iconName: "oilcan.fill"
        ),
        AlarmTemplate(
            id: "auto-registration",
            title: "Vehicle Registration Renewal",
            category: .vehicle,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Check DMV website for renewal options. Keep proof of insurance ready.",
            iconName: "doc.text.fill"
        ),
        AlarmTemplate(
            id: "auto-tire-rotation",
            title: "Tire Rotation",
            category: .vehicle,
            cycleType: .monthlyDate,
            repeatInterval: 6,
            daysOfMonth: [1],
            suggestedNote: "Rotate every 5,000-7,500 miles. Check tread depth and pressure.",
            iconName: "circle.circle.fill"
        ),
        AlarmTemplate(
            id: "auto-inspection",
            title: "Vehicle Inspection",
            category: .vehicle,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Schedule appointment before expiration. Check state requirements.",
            iconName: "checkmark.seal.fill"
        ),
        AlarmTemplate(
            id: "auto-insurance",
            title: "Auto Insurance Renewal",
            category: .vehicle,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Compare quotes before renewal. Review coverage limits.",
            iconName: "shield.fill"
        ),
    ]

    // MARK: - Health

    static let health: [AlarmTemplate] = [
        AlarmTemplate(
            id: "health-flea-med",
            title: "Pet Flea Medication",
            category: .health,
            cycleType: .monthlyDate,
            repeatInterval: 1,
            daysOfMonth: [1],
            suggestedNote: "Apply topical or give oral medication. Check weight for dosage.",
            iconName: "pawprint.fill"
        ),
        AlarmTemplate(
            id: "health-prescription",
            title: "Prescription Refill",
            category: .health,
            cycleType: .monthlyDate,
            repeatInterval: 1,
            daysOfMonth: [1],
            suggestedNote: "Call pharmacy or use app to request refill 7 days before running out.",
            iconName: "pills.fill"
        ),
        AlarmTemplate(
            id: "health-dental",
            title: "Dental Checkup",
            category: .health,
            cycleType: .monthlyDate,
            repeatInterval: 6,
            daysOfMonth: [1],
            suggestedNote: "Schedule cleaning and exam. Update insurance info if changed.",
            iconName: "mouth.fill"
        ),
        AlarmTemplate(
            id: "health-physical",
            title: "Annual Physical",
            category: .health,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Fasting may be required for bloodwork. Bring list of medications.",
            iconName: "stethoscope"
        ),
        AlarmTemplate(
            id: "health-eye-exam",
            title: "Eye Exam",
            category: .health,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Bring current glasses/contacts prescription. Check vision insurance.",
            iconName: "eye.fill"
        ),
    ]

    // MARK: - Finance

    static let finance: [AlarmTemplate] = [
        AlarmTemplate(
            id: "finance-rent",
            title: "Rent Payment",
            category: .finance,
            cycleType: .monthlyDate,
            repeatInterval: 1,
            daysOfMonth: [1],
            suggestedNote: "Set up autopay if available. Keep payment confirmations.",
            iconName: "house.fill"
        ),
        AlarmTemplate(
            id: "finance-insurance-premium",
            title: "Insurance Premium",
            category: .finance,
            cycleType: .monthlyDate,
            repeatInterval: 3,
            daysOfMonth: [1],
            suggestedNote: "Review coverage annually. Compare rates before renewal.",
            iconName: "shield.fill"
        ),
        AlarmTemplate(
            id: "finance-tax-filing",
            title: "Quarterly Tax Filing",
            category: .finance,
            cycleType: .monthlyDate,
            repeatInterval: 3,
            daysOfMonth: [15],
            suggestedNote: "Due dates: Jan 15, Apr 15, Jun 15, Sep 15. Use Form 1040-ES.",
            iconName: "doc.text.fill"
        ),
        AlarmTemplate(
            id: "finance-domain-renewal",
            title: "Domain Renewal",
            category: .finance,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Check auto-renewal settings. Consider multi-year registration for discounts.",
            iconName: "globe"
        ),
        AlarmTemplate(
            id: "finance-subscription-audit",
            title: "Subscription Audit",
            category: .finance,
            cycleType: .annual,
            repeatInterval: 1,
            daysOfMonth: [],
            suggestedNote: "Review all recurring charges. Cancel unused subscriptions.",
            iconName: "creditcard.fill"
        ),
    ]
}
