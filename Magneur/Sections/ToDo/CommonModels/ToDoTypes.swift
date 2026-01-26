import Foundation

// MARK: - Priority

enum TaskPriority: Int, Codable, CaseIterable {
    case p1 = 1  // Highest
    case p2 = 2
    case p3 = 3
    case p4 = 4  // Lowest (default)

    var displayName: String {
        switch self {
        case .p1: return "P1"
        case .p2: return "P2"
        case .p3: return "P3"
        case .p4: return "P4"
        }
    }

    var color: String {
        switch self {
        case .p1: return "#FF4444"  // Red
        case .p2: return "#FF9500"  // Orange
        case .p3: return "#5856D6"  // Indigo
        case .p4: return "#8E8E93"  // Gray
        }
    }
}

// MARK: - Task Status

enum TaskStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case cancelled
}

// MARK: - Recurrence Rule

struct TaskRecurrenceRule: Codable, Equatable, Hashable {
    enum Frequency: String, Codable, CaseIterable {
        case daily
        case weekly
        case monthly
        case yearly

        var displayName: String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
    }

    var frequency: Frequency
    var interval: Int  // Every N days/weeks/months
    var daysOfWeek: [Int]?  // 1=Sunday, 7=Saturday (for weekly)
    var dayOfMonth: Int?  // For monthly
    var endDate: Date?

    init(frequency: Frequency, interval: Int = 1, daysOfWeek: [Int]? = nil, dayOfMonth: Int? = nil, endDate: Date? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.daysOfWeek = daysOfWeek
        self.dayOfMonth = dayOfMonth
        self.endDate = endDate
    }

    static let daily = TaskRecurrenceRule(frequency: .daily)
    static let weekly = TaskRecurrenceRule(frequency: .weekly)
    static let monthly = TaskRecurrenceRule(frequency: .monthly)

    var displayString: String {
        if interval == 1 {
            return frequency.displayName
        } else {
            let unit: String
            switch frequency {
            case .daily: unit = interval > 1 ? "days" : "day"
            case .weekly: unit = interval > 1 ? "weeks" : "week"
            case .monthly: unit = interval > 1 ? "months" : "month"
            case .yearly: unit = interval > 1 ? "years" : "year"
            }
            return "Every \(interval) \(unit)"
        }
    }

    func nextOccurrence(after date: Date) -> Date {
        let calendar = Calendar.current

        switch frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: interval, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: interval, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: interval, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: interval, to: date) ?? date
        }
    }
}

// MARK: - Habit Completion Status

enum HabitCompletionStatus {
    case completed
    case missed
    case pending
    case future
}
