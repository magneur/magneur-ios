import Foundation

/// Utility for calculating and analyzing habit streaks
struct HabitStreakCalculator {

    /// Calculate the current streak for a habit based on completion dates
    static func calculateStreak(for completionDates: [Date], frequency: TaskRecurrenceRule.Frequency) -> Int {
        guard !completionDates.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get unique completion days sorted descending
        let completionDays = Set(completionDates.map { calendar.startOfDay(for: $0) })
            .sorted(by: >)

        switch frequency {
        case .daily:
            return calculateDailyStreak(completionDays: completionDays, today: today, calendar: calendar)
        case .weekly:
            return calculateWeeklyStreak(completionDays: completionDays, today: today, calendar: calendar)
        case .monthly:
            return calculateMonthlyStreak(completionDays: completionDays, today: today, calendar: calendar)
        case .yearly:
            return calculateYearlyStreak(completionDays: completionDays, today: today, calendar: calendar)
        }
    }

    private static func calculateDailyStreak(completionDays: [Date], today: Date, calendar: Calendar) -> Int {
        var streak = 0
        var checkDate = today

        // Allow streak to continue from yesterday if not completed today
        if !completionDays.contains(today) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  completionDays.contains(yesterday) else {
                return 0
            }
            checkDate = yesterday
        }

        // Count consecutive days backwards
        while completionDays.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }

    private static func calculateWeeklyStreak(completionDays: [Date], today: Date, calendar: Calendar) -> Int {
        var streak = 0
        var currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        // Check if current week has completion
        let currentWeekEnd = calendar.date(byAdding: .day, value: 7, to: currentWeekStart)!
        var hasCompletionInCurrentWeek = completionDays.contains { $0 >= currentWeekStart && $0 < currentWeekEnd }

        // If no completion this week and we're past Monday, check if last week was complete
        if !hasCompletionInCurrentWeek {
            guard let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart),
                  let lastWeekEnd = calendar.date(byAdding: .day, value: 7, to: lastWeekStart),
                  completionDays.contains(where: { $0 >= lastWeekStart && $0 < lastWeekEnd }) else {
                return 0
            }
            currentWeekStart = lastWeekStart
            hasCompletionInCurrentWeek = true
        }

        // Count consecutive weeks backwards
        while hasCompletionInCurrentWeek {
            streak += 1
            guard let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart),
                  let previousWeekEnd = calendar.date(byAdding: .day, value: 7, to: previousWeekStart) else { break }

            hasCompletionInCurrentWeek = completionDays.contains { $0 >= previousWeekStart && $0 < previousWeekEnd }
            currentWeekStart = previousWeekStart
        }

        return streak
    }

    private static func calculateMonthlyStreak(completionDays: [Date], today: Date, calendar: Calendar) -> Int {
        var streak = 0
        var currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        // Check if current month has completion
        let currentMonthEnd = calendar.date(byAdding: .month, value: 1, to: currentMonthStart)!
        var hasCompletionInCurrentMonth = completionDays.contains { $0 >= currentMonthStart && $0 < currentMonthEnd }

        // If no completion this month, check last month
        if !hasCompletionInCurrentMonth {
            guard let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart),
                  let lastMonthEnd = calendar.date(byAdding: .month, value: 1, to: lastMonthStart),
                  completionDays.contains(where: { $0 >= lastMonthStart && $0 < lastMonthEnd }) else {
                return 0
            }
            currentMonthStart = lastMonthStart
            hasCompletionInCurrentMonth = true
        }

        // Count consecutive months backwards
        while hasCompletionInCurrentMonth {
            streak += 1
            guard let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart),
                  let previousMonthEnd = calendar.date(byAdding: .month, value: 1, to: previousMonthStart) else { break }

            hasCompletionInCurrentMonth = completionDays.contains { $0 >= previousMonthStart && $0 < previousMonthEnd }
            currentMonthStart = previousMonthStart
        }

        return streak
    }

    private static func calculateYearlyStreak(completionDays: [Date], today: Date, calendar: Calendar) -> Int {
        var streak = 0
        var currentYearStart = calendar.date(from: calendar.dateComponents([.year], from: today))!

        let currentYearEnd = calendar.date(byAdding: .year, value: 1, to: currentYearStart)!
        var hasCompletionInCurrentYear = completionDays.contains { $0 >= currentYearStart && $0 < currentYearEnd }

        if !hasCompletionInCurrentYear {
            guard let lastYearStart = calendar.date(byAdding: .year, value: -1, to: currentYearStart),
                  let lastYearEnd = calendar.date(byAdding: .year, value: 1, to: lastYearStart),
                  completionDays.contains(where: { $0 >= lastYearStart && $0 < lastYearEnd }) else {
                return 0
            }
            currentYearStart = lastYearStart
            hasCompletionInCurrentYear = true
        }

        while hasCompletionInCurrentYear {
            streak += 1
            guard let previousYearStart = calendar.date(byAdding: .year, value: -1, to: currentYearStart),
                  let previousYearEnd = calendar.date(byAdding: .year, value: 1, to: previousYearStart) else { break }

            hasCompletionInCurrentYear = completionDays.contains { $0 >= previousYearStart && $0 < previousYearEnd }
            currentYearStart = previousYearStart
        }

        return streak
    }

    /// Generate dates for a calendar grid showing last N weeks
    static func calendarGridDates(weeks: Int = 12) -> [[Date]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find the start of this week (Sunday)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromSunday = weekday - 1
        guard let thisWeekStart = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) else {
            return []
        }

        // Go back N weeks
        guard let gridStart = calendar.date(byAdding: .weekOfYear, value: -(weeks - 1), to: thisWeekStart) else {
            return []
        }

        var grid: [[Date]] = []
        var currentDate = gridStart

        for _ in 0..<weeks {
            var week: [Date] = []
            for _ in 0..<7 {
                week.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            grid.append(week)
        }

        return grid
    }

    /// Get completion rate for the last N days
    static func completionRate(completionDates: [Date], days: Int) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else {
            return 0
        }

        let completionDays = Set(completionDates.map { calendar.startOfDay(for: $0) })
        var completedCount = 0

        for dayOffset in 0..<days {
            guard let checkDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            if completionDays.contains(checkDate) {
                completedCount += 1
            }
        }

        return Double(completedCount) / Double(days)
    }
}
