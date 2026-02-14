import AppIntents

enum CycleTypeAppEnum: String, AppEnum, CaseIterable {
    case weekly
    case monthly
    case annual
    case oneTime

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Schedule Type"
    }

    static var caseDisplayRepresentations: [CycleTypeAppEnum: DisplayRepresentation] {
        [
            .weekly: "Weekly",
            .monthly: "Monthly",
            .annual: "Annual",
            .oneTime: "One-Time"
        ]
    }

    var toCycleType: CycleType {
        switch self {
        case .weekly: return .weekly
        case .monthly: return .monthlyDate
        case .annual: return .annual
        case .oneTime: return .oneTime
        }
    }
}

// MARK: - Weekday

enum WeekdayAppEnum: Int, AppEnum, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Day of Week" }

    static var caseDisplayRepresentations: [WeekdayAppEnum: DisplayRepresentation] {
        [
            .sunday: "Sunday",
            .monday: "Monday",
            .tuesday: "Tuesday",
            .wednesday: "Wednesday",
            .thursday: "Thursday",
            .friday: "Friday",
            .saturday: "Saturday"
        ]
    }
}

// MARK: - Month

enum MonthAppEnum: Int, AppEnum, CaseIterable {
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Month" }

    static var caseDisplayRepresentations: [MonthAppEnum: DisplayRepresentation] {
        [
            .january: "January", .february: "February", .march: "March",
            .april: "April", .may: "May", .june: "June",
            .july: "July", .august: "August", .september: "September",
            .october: "October", .november: "November", .december: "December"
        ]
    }
}
