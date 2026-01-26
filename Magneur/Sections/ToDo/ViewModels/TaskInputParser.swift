import Foundation

/// Parses natural language input into structured task data
/// Examples:
/// - "Buy milk tomorrow 3pm p1 #shopping" -> Task with title, due date, priority, label
/// - "Call mom Friday p2 #family" -> Task with title, due date, priority, label
/// - "Submit report every Monday" -> Recurring task
struct TaskInputParser {

    struct ParsedTask {
        var title: String
        var dueDate: Date?
        var priority: TaskPriority
        var labels: [String]
        var recurrenceRule: TaskRecurrenceRule?
        var projectName: String?
    }

    func parse(_ input: String) -> ParsedTask {
        var remaining = input.trimmingCharacters(in: .whitespaces)
        var dueDate: Date?
        var priority: TaskPriority = .p4
        var labels: [String] = []
        var recurrenceRule: TaskRecurrenceRule?
        var projectName: String?

        // Extract labels (#tag)
        let labelRegex = try? NSRegularExpression(pattern: "#(\\w+)", options: [])
        if let regex = labelRegex {
            let range = NSRange(remaining.startIndex..., in: remaining)
            let matches = regex.matches(in: remaining, options: [], range: range)

            for match in matches.reversed() {
                if let tagRange = Range(match.range(at: 1), in: remaining) {
                    labels.insert(String(remaining[tagRange]), at: 0)
                }
                if let fullRange = Range(match.range, in: remaining) {
                    remaining.removeSubrange(fullRange)
                }
            }
        }

        // Extract priority (p1, p2, p3, p4)
        let priorityRegex = try? NSRegularExpression(pattern: "\\bp([1-4])\\b", options: .caseInsensitive)
        if let regex = priorityRegex {
            let range = NSRange(remaining.startIndex..., in: remaining)
            if let match = regex.firstMatch(in: remaining, options: [], range: range) {
                if let priorityRange = Range(match.range(at: 1), in: remaining),
                   let priorityInt = Int(remaining[priorityRange]),
                   let parsedPriority = TaskPriority(rawValue: priorityInt) {
                    priority = parsedPriority
                }
                if let fullRange = Range(match.range, in: remaining) {
                    remaining.removeSubrange(fullRange)
                }
            }
        }

        // Extract recurrence (every day, every week, every month, daily, weekly, monthly)
        let recurrencePatterns: [(pattern: String, rule: TaskRecurrenceRule)] = [
            ("\\bevery\\s+day\\b", .daily),
            ("\\bdaily\\b", .daily),
            ("\\bevery\\s+week\\b", .weekly),
            ("\\bweekly\\b", .weekly),
            ("\\bevery\\s+month\\b", .monthly),
            ("\\bmonthly\\b", .monthly),
            ("\\bevery\\s+monday\\b", TaskRecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [2])),
            ("\\bevery\\s+tuesday\\b", TaskRecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [3])),
            ("\\bevery\\s+wednesday\\b", TaskRecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [4])),
            ("\\bevery\\s+thursday\\b", TaskRecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [5])),
            ("\\bevery\\s+friday\\b", TaskRecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [6])),
            ("\\bevery\\s+saturday\\b", TaskRecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [7])),
            ("\\bevery\\s+sunday\\b", TaskRecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [1])),
        ]

        for (pattern, rule) in recurrencePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(remaining.startIndex..., in: remaining)
                if let match = regex.firstMatch(in: remaining, options: [], range: range) {
                    recurrenceRule = rule
                    if let fullRange = Range(match.range, in: remaining) {
                        remaining.removeSubrange(fullRange)
                    }
                    break
                }
            }
        }

        // Extract date/time
        dueDate = parseDate(from: &remaining)

        // Extract project (/project or @project)
        let projectRegex = try? NSRegularExpression(pattern: "[@/](\\w+)", options: [])
        if let regex = projectRegex {
            let range = NSRange(remaining.startIndex..., in: remaining)
            if let match = regex.firstMatch(in: remaining, options: [], range: range) {
                if let projectRange = Range(match.range(at: 1), in: remaining) {
                    projectName = String(remaining[projectRange])
                }
                if let fullRange = Range(match.range, in: remaining) {
                    remaining.removeSubrange(fullRange)
                }
            }
        }

        // Clean up title
        let title = remaining
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "  ", with: " ")

        return ParsedTask(
            title: title,
            dueDate: dueDate,
            priority: priority,
            labels: labels,
            recurrenceRule: recurrenceRule,
            projectName: projectName
        )
    }

    private func parseDate(from text: inout String) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        // Try relative dates first
        let relativeDates: [(pattern: String, offset: () -> Date?)] = [
            ("\\btoday\\b", { calendar.startOfDay(for: now) }),
            ("\\btomorrow\\b", { calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) }),
            ("\\byesterday\\b", { calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)) }),
            ("\\bnext\\s+week\\b", { calendar.date(byAdding: .weekOfYear, value: 1, to: now) }),
            ("\\bnext\\s+month\\b", { calendar.date(byAdding: .month, value: 1, to: now) }),
        ]

        for (pattern, offset) in relativeDates {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let fullRange = Range(match.range, in: text) {
                        text.removeSubrange(fullRange)
                    }
                    var date = offset()

                    // Also parse time if present
                    if let time = parseTime(from: &text), let baseDate = date {
                        date = combineDateAndTime(date: baseDate, time: time)
                    }

                    return date
                }
            }
        }

        // Try weekday names
        let weekdays = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        for (index, weekday) in weekdays.enumerated() {
            let pattern = "\\b\(weekday)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let fullRange = Range(match.range, in: text) {
                        text.removeSubrange(fullRange)
                    }

                    // Find next occurrence of this weekday
                    let targetWeekday = index + 1  // Calendar uses 1=Sunday
                    var date = now
                    while calendar.component(.weekday, from: date) != targetWeekday {
                        date = calendar.date(byAdding: .day, value: 1, to: date)!
                    }
                    date = calendar.startOfDay(for: date)

                    // Also parse time if present
                    if let time = parseTime(from: &text) {
                        date = combineDateAndTime(date: date, time: time)!
                    }

                    return date
                }
            }
        }

        // Try time only (assumes today)
        if let time = parseTime(from: &text) {
            return combineDateAndTime(date: calendar.startOfDay(for: now), time: time)
        }

        return nil
    }

    private func parseTime(from text: inout String) -> (hour: Int, minute: Int)? {
        // Match patterns like "3pm", "3:30pm", "15:30", "3 pm"
        let timePatterns: [(String, (String) -> (Int, Int)?)] = [
            // 3:30pm, 3:30 pm
            ("\\b(\\d{1,2}):(\\d{2})\\s*(am|pm)\\b", { match in
                let parts = match.lowercased()
                    .replacingOccurrences(of: "am", with: " am")
                    .replacingOccurrences(of: "pm", with: " pm")
                    .components(separatedBy: CharacterSet(charactersIn: ": "))
                    .filter { !$0.isEmpty }
                guard parts.count >= 3,
                      var hour = Int(parts[0]),
                      let minute = Int(parts[1]) else { return nil }

                let isPM = parts[2].lowercased() == "pm"
                if isPM && hour < 12 { hour += 12 }
                if !isPM && hour == 12 { hour = 0 }

                return (hour, minute)
            }),
            // 3pm, 3 pm
            ("\\b(\\d{1,2})\\s*(am|pm)\\b", { match in
                let cleaned = match.lowercased().replacingOccurrences(of: " ", with: "")
                let isPM = cleaned.hasSuffix("pm")
                let hourStr = cleaned.replacingOccurrences(of: "am", with: "").replacingOccurrences(of: "pm", with: "")
                guard var hour = Int(hourStr) else { return nil }

                if isPM && hour < 12 { hour += 12 }
                if !isPM && hour == 12 { hour = 0 }

                return (hour, 0)
            }),
            // 15:30 (24-hour)
            ("\\b([01]?\\d|2[0-3]):([0-5]\\d)\\b", { match in
                let parts = match.components(separatedBy: ":")
                guard parts.count == 2,
                      let hour = Int(parts[0]),
                      let minute = Int(parts[1]),
                      hour >= 0 && hour < 24 else { return nil }
                return (hour, minute)
            }),
        ]

        for (pattern, parser) in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range),
                   let matchRange = Range(match.range, in: text) {
                    let matchedText = String(text[matchRange])
                    if let time = parser(matchedText) {
                        text.removeSubrange(matchRange)
                        return time
                    }
                }
            }
        }

        return nil
    }

    private func combineDateAndTime(date: Date, time: (hour: Int, minute: Int)) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = time.hour
        components.minute = time.minute
        return calendar.date(from: components)
    }
}

// MARK: - Preview Helper

extension TaskInputParser.ParsedTask: CustomStringConvertible {
    var description: String {
        var parts: [String] = ["Title: \"\(title)\""]

        if let date = dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            parts.append("Due: \(formatter.string(from: date))")
        }

        parts.append("Priority: \(priority.displayName)")

        if !labels.isEmpty {
            parts.append("Labels: \(labels.joined(separator: ", "))")
        }

        if let rule = recurrenceRule {
            parts.append("Recurrence: \(rule.displayString)")
        }

        if let project = projectName {
            parts.append("Project: \(project)")
        }

        return parts.joined(separator: " | ")
    }
}
