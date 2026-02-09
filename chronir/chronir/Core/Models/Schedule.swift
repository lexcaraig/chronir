import Foundation

enum Schedule: Codable, Hashable {
    case weekly(daysOfWeek: [Int], interval: Int)
    case monthlyDate(daysOfMonth: [Int], interval: Int)
    case monthlyRelative(weekOfMonth: Int, dayOfWeek: Int, interval: Int)
    case annual(month: Int, dayOfMonth: Int, interval: Int)
    case customDays(intervalDays: Int, startDate: Date)

    var cycleType: CycleType {
        switch self {
        case .weekly: return .weekly
        case .monthlyDate: return .monthlyDate
        case .monthlyRelative: return .monthlyRelative
        case .annual: return .annual
        case .customDays: return .customDays
        }
    }

    // MARK: - Custom Codable

    private enum CodingKeys: String, CodingKey {
        case type
        case daysOfWeek, interval, dayOfMonth, daysOfMonth, weekOfMonth, dayOfWeek, month, intervalDays, startDate
    }

    private enum ScheduleType: String, Codable {
        case weekly, monthlyDate, monthlyRelative, annual, customDays
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .weekly(let daysOfWeek, let interval):
            try container.encode(ScheduleType.weekly, forKey: .type)
            try container.encode(daysOfWeek, forKey: .daysOfWeek)
            try container.encode(interval, forKey: .interval)
        case .monthlyDate(let daysOfMonth, let interval):
            try container.encode(ScheduleType.monthlyDate, forKey: .type)
            try container.encode(daysOfMonth, forKey: .daysOfMonth)
            try container.encode(interval, forKey: .interval)
        case .monthlyRelative(let weekOfMonth, let dayOfWeek, let interval):
            try container.encode(ScheduleType.monthlyRelative, forKey: .type)
            try container.encode(weekOfMonth, forKey: .weekOfMonth)
            try container.encode(dayOfWeek, forKey: .dayOfWeek)
            try container.encode(interval, forKey: .interval)
        case .annual(let month, let dayOfMonth, let interval):
            try container.encode(ScheduleType.annual, forKey: .type)
            try container.encode(month, forKey: .month)
            try container.encode(dayOfMonth, forKey: .dayOfMonth)
            try container.encode(interval, forKey: .interval)
        case .customDays(let intervalDays, let startDate):
            try container.encode(ScheduleType.customDays, forKey: .type)
            try container.encode(intervalDays, forKey: .intervalDays)
            try container.encode(startDate, forKey: .startDate)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ScheduleType.self, forKey: .type)
        switch type {
        case .weekly:
            let daysOfWeek = try container.decode([Int].self, forKey: .daysOfWeek)
            let interval = try container.decode(Int.self, forKey: .interval)
            self = .weekly(daysOfWeek: daysOfWeek, interval: interval)
        case .monthlyDate:
            let interval = try container.decode(Int.self, forKey: .interval)
            if let daysOfMonth = try? container.decode([Int].self, forKey: .daysOfMonth) {
                self = .monthlyDate(daysOfMonth: daysOfMonth, interval: interval)
            } else {
                let dayOfMonth = try container.decode(Int.self, forKey: .dayOfMonth)
                self = .monthlyDate(daysOfMonth: [dayOfMonth], interval: interval)
            }
        case .monthlyRelative:
            let weekOfMonth = try container.decode(Int.self, forKey: .weekOfMonth)
            let dayOfWeek = try container.decode(Int.self, forKey: .dayOfWeek)
            let interval = try container.decode(Int.self, forKey: .interval)
            self = .monthlyRelative(weekOfMonth: weekOfMonth, dayOfWeek: dayOfWeek, interval: interval)
        case .annual:
            let month = try container.decode(Int.self, forKey: .month)
            let dayOfMonth = try container.decode(Int.self, forKey: .dayOfMonth)
            let interval = try container.decode(Int.self, forKey: .interval)
            self = .annual(month: month, dayOfMonth: dayOfMonth, interval: interval)
        case .customDays:
            let intervalDays = try container.decode(Int.self, forKey: .intervalDays)
            let startDate = try container.decode(Date.self, forKey: .startDate)
            self = .customDays(intervalDays: intervalDays, startDate: startDate)
        }
    }
}
