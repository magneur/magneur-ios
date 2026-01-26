import Foundation
import SwiftData

// MARK: - StoredToDoTask

@Model
final class StoredToDoTask {
    @Attribute(.unique) var id: String
    var title: String
    var notes: String
    var priorityRaw: Int
    var statusRaw: String
    var dueDate: Date?
    var recurrenceRuleJSON: String?
    var projectId: String?
    var labelsJSON: String?
    var parentTaskId: String?
    var subtaskIdsJSON: String?
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    init(
        id: String = UUID().uuidString,
        title: String,
        notes: String = "",
        priorityRaw: Int = 4,
        statusRaw: String = "pending",
        dueDate: Date? = nil,
        recurrenceRuleJSON: String? = nil,
        projectId: String? = nil,
        labelsJSON: String? = nil,
        parentTaskId: String? = nil,
        subtaskIdsJSON: String? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priorityRaw = priorityRaw
        self.statusRaw = statusRaw
        self.dueDate = dueDate
        self.recurrenceRuleJSON = recurrenceRuleJSON
        self.projectId = projectId
        self.labelsJSON = labelsJSON
        self.parentTaskId = parentTaskId
        self.subtaskIdsJSON = subtaskIdsJSON
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }

    func toTask() -> ToDoTask {
        ToDoTask(stored: self)
    }
}

// MARK: - StoredProject

@Model
final class StoredProject {
    @Attribute(.unique) var id: String
    var name: String
    var color: String
    var iconName: String
    var sortOrder: Int
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        color: String = "#5856D6",
        iconName: String = "folder.fill",
        sortOrder: Int = 0,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.iconName = iconName
        self.sortOrder = sortOrder
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func toProject() -> Project {
        Project(stored: self)
    }
}

// MARK: - StoredHabit

@Model
final class StoredHabit {
    @Attribute(.unique) var id: String
    var name: String
    var notes: String
    var color: String
    var iconName: String
    var recurrenceRuleJSON: String
    var targetPerPeriod: Int
    var streakCurrent: Int
    var streakBest: Int
    var completionDatesJSON: String?
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        notes: String = "",
        color: String = "#5856D6",
        iconName: String = "checkmark.circle.fill",
        recurrenceRuleJSON: String = "",
        targetPerPeriod: Int = 1,
        streakCurrent: Int = 0,
        streakBest: Int = 0,
        completionDatesJSON: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.color = color
        self.iconName = iconName
        self.recurrenceRuleJSON = recurrenceRuleJSON
        self.targetPerPeriod = targetPerPeriod
        self.streakCurrent = streakCurrent
        self.streakBest = streakBest
        self.completionDatesJSON = completionDatesJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }

    func toHabit() -> Habit {
        Habit(stored: self)
    }
}

// MARK: - Conversion Extensions

extension ToDoTask {
    init(stored: StoredToDoTask) {
        self.id = stored.id
        self.title = stored.title
        self.notes = stored.notes
        self.priority = TaskPriority(rawValue: stored.priorityRaw) ?? .p4
        self.status = TaskStatus(rawValue: stored.statusRaw) ?? .pending
        self.dueDate = stored.dueDate
        self.recurrenceRule = Self.decodeTaskRecurrenceRule(from: stored.recurrenceRuleJSON)
        self.projectId = stored.projectId
        self.labels = Self.decodeStringArray(from: stored.labelsJSON)
        self.parentTaskId = stored.parentTaskId
        self.subtaskIds = Self.decodeStringArray(from: stored.subtaskIdsJSON)
        self.sortOrder = stored.sortOrder
        self.createdAt = stored.createdAt
        self.updatedAt = stored.updatedAt
        self.completedAt = stored.completedAt
    }

    func toStoredTask() -> StoredToDoTask {
        StoredToDoTask(
            id: id ?? UUID().uuidString,
            title: title,
            notes: notes,
            priorityRaw: priority.rawValue,
            statusRaw: status.rawValue,
            dueDate: dueDate,
            recurrenceRuleJSON: recurrenceRuleJSON(),
            projectId: projectId,
            labelsJSON: labelsJSON(),
            parentTaskId: parentTaskId,
            subtaskIdsJSON: subtaskIdsJSON(),
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt
        )
    }
}

extension Project {
    init(stored: StoredProject) {
        self.id = stored.id
        self.name = stored.name
        self.color = stored.color
        self.iconName = stored.iconName
        self.sortOrder = stored.sortOrder
        self.isArchived = stored.isArchived
        self.createdAt = stored.createdAt
        self.updatedAt = stored.updatedAt
    }

    func toStoredProject() -> StoredProject {
        StoredProject(
            id: id ?? UUID().uuidString,
            name: name,
            color: color,
            iconName: iconName,
            sortOrder: sortOrder,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Habit {
    init(stored: StoredHabit) {
        self.id = stored.id
        self.name = stored.name
        self.notes = stored.notes
        self.color = stored.color
        self.iconName = stored.iconName
        self.recurrenceRule = Self.decodeTaskRecurrenceRule(from: stored.recurrenceRuleJSON)
        self.targetPerPeriod = stored.targetPerPeriod
        self.streakCurrent = stored.streakCurrent
        self.streakBest = stored.streakBest
        self.completionDates = Self.decodeDates(from: stored.completionDatesJSON)
        self.createdAt = stored.createdAt
        self.updatedAt = stored.updatedAt
        self.isArchived = stored.isArchived
    }

    func toStoredHabit() -> StoredHabit {
        StoredHabit(
            id: id ?? UUID().uuidString,
            name: name,
            notes: notes,
            color: color,
            iconName: iconName,
            recurrenceRuleJSON: recurrenceRuleJSON() ?? "",
            targetPerPeriod: targetPerPeriod,
            streakCurrent: streakCurrent,
            streakBest: streakBest,
            completionDatesJSON: completionDatesJSON(),
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived
        )
    }
}
