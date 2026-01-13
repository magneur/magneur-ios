//
//  RecurrenceParser.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import Foundation

// MARK: - Recurrence Frequency

/// Represents the frequency of a recurrence rule (RFC 5545)
enum RecurrenceFrequency: String, CaseIterable {
    case daily = "DAILY"
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
    case yearly = "YEARLY"
}

// MARK: - Weekday

/// Represents days of the week for recurrence rules
enum RecurrenceWeekday: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var symbol: String {
        switch self {
        case .sunday: return "SU"
        case .monday: return "MO"
        case .tuesday: return "TU"
        case .wednesday: return "WE"
        case .thursday: return "TH"
        case .friday: return "FR"
        case .saturday: return "SA"
        }
    }
    
    static func from(symbol: String) -> RecurrenceWeekday? {
        switch symbol.uppercased() {
        case "SU": return .sunday
        case "MO": return .monday
        case "TU": return .tuesday
        case "WE": return .wednesday
        case "TH": return .thursday
        case "FR": return .friday
        case "SA": return .saturday
        default: return nil
        }
    }
}

// MARK: - Recurrence Rule

/// A parsed recurrence rule from an RRULE string
struct RecurrenceRule {
    var frequency: RecurrenceFrequency
    var interval: Int = 1
    var count: Int?
    var until: Date?
    var byWeekday: [RecurrenceWeekday] = []
    var byMonthDay: [Int] = []
    var byMonth: [Int] = []
    
    /// Parse an RRULE string into a RecurrenceRule
    static func parse(_ rruleString: String) -> RecurrenceRule? {
        // Remove RRULE: prefix if present
        var ruleString = rruleString
        if let range = rruleString.range(of: "RRULE:") {
            ruleString = String(rruleString[range.upperBound...])
        }
        
        // Also handle simple format like FREQ=WEEKLY
        let components = ruleString.components(separatedBy: ";")
        var params: [String: String] = [:]
        
        for component in components {
            let parts = component.components(separatedBy: "=")
            guard parts.count == 2 else { continue }
            params[parts[0].uppercased()] = parts[1]
        }
        
        // Frequency is required
        guard let freqString = params["FREQ"],
              let frequency = RecurrenceFrequency(rawValue: freqString) else {
            return nil
        }
        
        var rule = RecurrenceRule(frequency: frequency)
        
        // Interval
        if let intervalString = params["INTERVAL"], let interval = Int(intervalString) {
            rule.interval = max(1, interval)
        }
        
        // Count
        if let countString = params["COUNT"], let count = Int(countString) {
            rule.count = count
        }
        
        // Until date
        if let untilString = params["UNTIL"] {
            rule.until = parseDate(untilString)
        }
        
        // By weekday (BYDAY)
        if let bydayString = params["BYDAY"] {
            let days = bydayString.components(separatedBy: ",")
            rule.byWeekday = days.compactMap { dayStr in
                // Handle cases like "1MO" (first Monday) - extract just the day part
                let cleaned = dayStr.trimmingCharacters(in: CharacterSet.letters.inverted)
                return RecurrenceWeekday.from(symbol: cleaned)
            }
        }
        
        // By month day (BYMONTHDAY)
        if let byMonthdayString = params["BYMONTHDAY"] {
            rule.byMonthDay = byMonthdayString.components(separatedBy: ",")
                .compactMap { Int($0) }
                .filter { (-31...31).contains($0) && $0 != 0 }
        }
        
        // By month (BYMONTH)
        if let byMonthString = params["BYMONTH"] {
            rule.byMonth = byMonthString.components(separatedBy: ",")
                .compactMap { Int($0) }
                .filter { (1...12).contains($0) }
        }
        
        return rule
    }
    
    /// Parse a date string in RRULE format
    private static func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "yyyyMMdd'T'HHmmss'Z'",
            "yyyyMMdd'T'HHmmss",
            "yyyyMMdd"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
}

// MARK: - Recurrence Generator

/// Generates occurrence dates from a recurrence rule
struct RecurrenceGenerator {
    
    /// Generate all occurrences of a recurrence within a date range
    static func generateOccurrences(
        for rule: RecurrenceRule,
        startDate: Date,
        inRange range: DateInterval,
        calendar: Calendar = .current
    ) -> [Date] {
        var occurrences: [Date] = []
        var currentDate = startDate
        var occurrenceCount = 0
        let maxIterations = 1000 // Safety limit
        var iterations = 0
        
        while currentDate <= range.end && iterations < maxIterations {
            iterations += 1
            
            // Check if we've hit the count limit
            if let count = rule.count, occurrenceCount >= count {
                break
            }
            
            // Check if we've hit the until date
            if let until = rule.until, currentDate > until {
                break
            }
            
            // Check if this occurrence falls within the range
            if currentDate >= range.start {
                // For rules with byWeekday, check if the current day matches
                if !rule.byWeekday.isEmpty {
                    let weekday = calendar.component(.weekday, from: currentDate)
                    if let recurrenceWeekday = RecurrenceWeekday(rawValue: weekday),
                       rule.byWeekday.contains(recurrenceWeekday) {
                        occurrences.append(currentDate)
                        occurrenceCount += 1
                    }
                }
                // For rules with byMonthDay, check if the current day of month matches
                else if !rule.byMonthDay.isEmpty {
                    let dayOfMonth = calendar.component(.day, from: currentDate)
                    if rule.byMonthDay.contains(dayOfMonth) {
                        occurrences.append(currentDate)
                        occurrenceCount += 1
                    }
                }
                // For rules with byMonth, check if the current month matches
                else if !rule.byMonth.isEmpty {
                    let month = calendar.component(.month, from: currentDate)
                    if rule.byMonth.contains(month) {
                        occurrences.append(currentDate)
                        occurrenceCount += 1
                    }
                }
                // Simple frequency-based occurrence
                else {
                    occurrences.append(currentDate)
                    occurrenceCount += 1
                }
            }
            
            // Advance to next potential occurrence based on frequency
            currentDate = nextDate(after: currentDate, for: rule, calendar: calendar)
        }
        
        return occurrences
    }
    
    /// Calculate the next date based on frequency and interval
    private static func nextDate(
        after date: Date,
        for rule: RecurrenceRule,
        calendar: Calendar
    ) -> Date {
        var dateComponent: Calendar.Component
        var incrementValue = 1
        
        switch rule.frequency {
        case .daily:
            dateComponent = .day
            // For weekly rules with specific days, still iterate daily to check each day
            if !rule.byWeekday.isEmpty {
                incrementValue = 1
            } else {
                incrementValue = rule.interval
            }
        case .weekly:
            if !rule.byWeekday.isEmpty {
                // When specific days are set, iterate daily to find matching days
                dateComponent = .day
                incrementValue = 1
            } else {
                dateComponent = .weekOfYear
                incrementValue = rule.interval
            }
        case .monthly:
            if !rule.byMonthDay.isEmpty {
                // When specific days are set, iterate daily
                dateComponent = .day
                incrementValue = 1
            } else {
                dateComponent = .month
                incrementValue = rule.interval
            }
        case .yearly:
            dateComponent = .year
            incrementValue = rule.interval
        }
        
        return calendar.date(byAdding: dateComponent, value: incrementValue, to: date) ?? date
    }
}
