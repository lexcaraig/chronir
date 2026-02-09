import Foundation

struct TimeOfDay: Codable, Hashable, Comparable, Sendable {
    let hour: Int
    let minute: Int

    init(hour: Int, minute: Int) {
        self.hour = max(0, min(23, hour))
        self.minute = max(0, min(59, minute))
    }

    init(from date: Date, calendar: Calendar = .current) {
        self.hour = calendar.component(.hour, from: date)
        self.minute = calendar.component(.minute, from: date)
    }

    func asDateToday(calendar: Calendar = .current) -> Date {
        calendar.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }

    var formatted: String {
        let date = asDateToday()
        return date.formatted(date: .omitted, time: .shortened)
    }

    static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool {
        if lhs.hour != rhs.hour { return lhs.hour < rhs.hour }
        return lhs.minute < rhs.minute
    }
}
