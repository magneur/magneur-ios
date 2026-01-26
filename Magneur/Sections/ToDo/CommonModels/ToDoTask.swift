import Foundation

// MARK: - ToDoTask

struct ToDoTask: Codable, Identifiable, Hashable {
    var id: String?
    var title: String
    var notes: String
    var priority: TaskPriority
    var status: TaskStatus
    var dueDate: Date?
    var recurrenceRule: TaskRecurrenceRule?
    var projectId: String?
    var labels: [String]
    var parentTaskId: String?  // For subtasks
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    // Computed: subtasks loaded separately
    var subtaskIds: [String]

    init(
        id: String? = nil,
        title: String,
        notes: String = "",
        priority: TaskPriority = .p4,
        status: TaskStatus = .pending,
        dueDate: Date? = nil,
        recurrenceRule: TaskRecurrenceRule? = nil,
        projectId: String? = nil,
        labels: [String] = [],
        parentTaskId: String? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        subtaskIds: [String] = []
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priority = priority
        self.status = status
        self.dueDate = dueDate
        self.recurrenceRule = recurrenceRule
        self.projectId = projectId
        self.labels = labels
        self.parentTaskId = parentTaskId
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.subtaskIds = subtaskIds
    }

    // MARK: - Computed Properties

    var isCompleted: Bool {
        status == .completed
    }

    var isOverdue: Bool {
        guard let dueDate, status == .pending else { return false }
        return dueDate < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var isDueTomorrow: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }

    var isSubtask: Bool {
        parentTaskId != nil
    }

    var hasSubtasks: Bool {
        !subtaskIds.isEmpty
    }

    var isRecurring: Bool {
        recurrenceRule != nil
    }

    var formattedDueDate: String? {
        guard let dueDate else { return nil }

        let calendar = Calendar.current
        if calendar.isDateInToday(dueDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(dueDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(dueDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            if calendar.isDate(dueDate, equalTo: Date(), toGranularity: .year) {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "MMM d, yyyy"
            }
            return formatter.string(from: dueDate)
        }
    }

    // MARK: - Factory Methods

    static func quick(title: String) -> ToDoTask {
        ToDoTask(title: title)
    }

    static func withDueDate(_ title: String, dueDate: Date) -> ToDoTask {
        ToDoTask(title: title, dueDate: dueDate)
    }

    // MARK: - JSON Helpers

    func labelsJSON() -> String? {
        guard let data = try? JSONEncoder().encode(labels) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func subtaskIdsJSON() -> String? {
        guard let data = try? JSONEncoder().encode(subtaskIds) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func recurrenceRuleJSON() -> String? {
        guard let rule = recurrenceRule,
              let data = try? JSONEncoder().encode(rule) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decodeStringArray(from json: String?) -> [String] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    static func decodeTaskRecurrenceRule(from json: String?) -> TaskRecurrenceRule? {
        guard let json, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(TaskRecurrenceRule.self, from: data)
    }

    // MARK: - Mutations

    mutating func complete() {
        status = .completed
        completedAt = Date()
        updatedAt = Date()
    }

    mutating func uncomplete() {
        status = .pending
        completedAt = nil
        updatedAt = Date()
    }

    func creatingNextRecurrence() -> ToDoTask? {
        guard let rule = recurrenceRule, let dueDate else { return nil }

        let nextDate = rule.nextOccurrence(after: dueDate)

        // Check if past end date
        if let endDate = rule.endDate, nextDate > endDate {
            return nil
        }

        return ToDoTask(
            title: title,
            notes: notes,
            priority: priority,
            status: .pending,
            dueDate: nextDate,
            recurrenceRule: rule,
            projectId: projectId,
            labels: labels,
            parentTaskId: nil,  // Don't copy subtasks
            sortOrder: sortOrder
        )
    }
}
