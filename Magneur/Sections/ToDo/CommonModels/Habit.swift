import Foundation

struct Habit: Codable, Identifiable, Hashable {
    var id: String?
    var name: String
    var notes: String
    var color: String
    var iconName: String
    var recurrenceRule: TaskRecurrenceRule
    var targetPerPeriod: Int  // How many times per period (e.g., 3 times per week)
    var streakCurrent: Int
    var streakBest: Int
    var completionDates: [Date]
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(
        id: String? = nil,
        name: String,
        notes: String = "",
        color: String = "#5856D6",
        iconName: String = "checkmark.circle.fill",
        recurrenceRule: TaskRecurrenceRule = .daily,
        targetPerPeriod: Int = 1,
        streakCurrent: Int = 0,
        streakBest: Int = 0,
        completionDates: [Date] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.color = color
        self.iconName = iconName
        self.recurrenceRule = recurrenceRule
        self.targetPerPeriod = targetPerPeriod
        self.streakCurrent = streakCurrent
        self.streakBest = streakBest
        self.completionDates = completionDates
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }

    // MARK: - Computed Properties

    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completionDates.contains { calendar.isDateInToday($0) }
    }

    var completionsThisPeriod: Int {
        let calendar = Calendar.current
        let now = Date()

        switch recurrenceRule.frequency {
        case .daily:
            return completionDates.filter { calendar.isDateInToday($0) }.count
        case .weekly:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return completionDates.filter { $0 >= weekStart && $0 <= now }.count
        case .monthly:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return completionDates.filter { $0 >= monthStart && $0 <= now }.count
        case .yearly:
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return completionDates.filter { $0 >= yearStart && $0 <= now }.count
        }
    }

    var progressThisPeriod: Double {
        guard targetPerPeriod > 0 else { return 0 }
        return min(1.0, Double(completionsThisPeriod) / Double(targetPerPeriod))
    }

    var periodDescription: String {
        switch recurrenceRule.frequency {
        case .daily: return "today"
        case .weekly: return "this week"
        case .monthly: return "this month"
        case .yearly: return "this year"
        }
    }

    var targetDescription: String {
        let unit: String
        switch recurrenceRule.frequency {
        case .daily: unit = "day"
        case .weekly: unit = "week"
        case .monthly: unit = "month"
        case .yearly: unit = "year"
        }

        if targetPerPeriod == 1 {
            return "Once per \(unit)"
        } else {
            return "\(targetPerPeriod)x per \(unit)"
        }
    }

    // MARK: - Mutations

    mutating func markCompleted() {
        let now = Date()
        completionDates.append(now)
        updatedAt = now
        recalculateStreak()
    }

    mutating func unmarkCompletedToday() {
        let calendar = Calendar.current
        completionDates.removeAll { calendar.isDateInToday($0) }
        updatedAt = Date()
        recalculateStreak()
    }

    mutating func recalculateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get unique completion days
        let completionDays = Set(completionDates.map { calendar.startOfDay(for: $0) })

        // For daily habits, count consecutive days ending today or yesterday
        guard recurrenceRule.frequency == .daily else {
            // For non-daily, just track if target met
            streakCurrent = progressThisPeriod >= 1.0 ? 1 : 0
            streakBest = max(streakBest, streakCurrent)
            return
        }

        var streak = 0
        var checkDate = today

        // If not completed today, start from yesterday
        if !completionDays.contains(today) {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if !completionDays.contains(yesterday) {
                // Streak is broken
                streakCurrent = 0
                return
            }
            checkDate = yesterday
        }

        // Count backwards
        while completionDays.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        streakCurrent = streak
        streakBest = max(streakBest, streak)
    }

    // MARK: - Calendar Grid

    func completionStatus(for date: Date) -> HabitCompletionStatus {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())

        if startOfDate > today {
            return .future
        }

        let completed = completionDates.contains { calendar.isDate($0, inSameDayAs: date) }

        if completed {
            return .completed
        } else if startOfDate < today {
            return .missed
        } else {
            return .pending
        }
    }

    // MARK: - JSON Helpers

    func completionDatesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(completionDates) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func recurrenceRuleJSON() -> String? {
        guard let data = try? JSONEncoder().encode(recurrenceRule) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decodeDates(from json: String?) -> [Date] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([Date].self, from: data)) ?? []
    }

    static func decodeTaskRecurrenceRule(from json: String?) -> TaskRecurrenceRule {
        guard let json, let data = json.data(using: .utf8),
              let rule = try? JSONDecoder().decode(TaskRecurrenceRule.self, from: data) else {
            return .daily
        }
        return rule
    }

    // MARK: - Predefined Icons

    static let availableIcons: [String] = [
        "checkmark.circle.fill",
        "flame.fill",
        "drop.fill",
        "heart.fill",
        "figure.run",
        "dumbbell.fill",
        "bed.double.fill",
        "book.fill",
        "pencil",
        "brain.head.profile",
        "leaf.fill",
        "sun.max.fill",
        "moon.fill",
        "pills.fill",
        "fork.knife",
        "cup.and.saucer.fill"
    ]
}
