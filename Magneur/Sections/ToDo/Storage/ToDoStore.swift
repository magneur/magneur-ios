import Foundation
import SwiftData

@Observable
final class ToDoStore {
    static let shared = ToDoStore()

    private var modelContext: ModelContext?

    private init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Task Operations

    func fetchAllTasks() -> [ToDoTask] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredToDoTask>(
            sortBy: [
                SortDescriptor(\.sortOrder),
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toTask() }
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }

    func fetchTasks(forProject projectId: String?) -> [ToDoTask] {
        guard let context = modelContext else { return [] }

        var descriptor: FetchDescriptor<StoredToDoTask>

        if let projectId {
            descriptor = FetchDescriptor<StoredToDoTask>(
                predicate: #Predicate { $0.projectId == projectId && $0.parentTaskId == nil },
                sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt, order: .reverse)]
            )
        } else {
            // Inbox: tasks without project
            descriptor = FetchDescriptor<StoredToDoTask>(
                predicate: #Predicate { $0.projectId == nil && $0.parentTaskId == nil },
                sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt, order: .reverse)]
            )
        }

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toTask() }
        } catch {
            print("Failed to fetch project tasks: \(error)")
            return []
        }
    }

    func fetchSubtasks(forTask parentId: String) -> [ToDoTask] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredToDoTask>(
            predicate: #Predicate { $0.parentTaskId == parentId },
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toTask() }
        } catch {
            print("Failed to fetch subtasks: \(error)")
            return []
        }
    }

    func fetchTodayTasks() -> [ToDoTask] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        // Fetch overdue and today's tasks that are pending and not subtasks
        let descriptor = FetchDescriptor<StoredToDoTask>(
            predicate: #Predicate {
                $0.statusRaw == "pending" &&
                $0.parentTaskId == nil &&
                $0.dueDate != nil &&
                $0.dueDate! < endOfToday
            },
            sortBy: [
                SortDescriptor(\.dueDate),
                SortDescriptor(\.priorityRaw),
                SortDescriptor(\.sortOrder)
            ]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toTask() }
        } catch {
            print("Failed to fetch today tasks: \(error)")
            return []
        }
    }

    func fetchUpcomingTasks(days: Int = 7) -> [ToDoTask] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        let futureDate = calendar.date(byAdding: .day, value: days, to: Date())!

        let descriptor = FetchDescriptor<StoredToDoTask>(
            predicate: #Predicate {
                $0.statusRaw == "pending" &&
                $0.parentTaskId == nil &&
                $0.dueDate != nil &&
                $0.dueDate! >= endOfToday &&
                $0.dueDate! <= futureDate
            },
            sortBy: [SortDescriptor(\.dueDate), SortDescriptor(\.priorityRaw)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toTask() }
        } catch {
            print("Failed to fetch upcoming tasks: \(error)")
            return []
        }
    }

    func searchTasks(query: String) -> [ToDoTask] {
        guard let context = modelContext, !query.isEmpty else { return [] }

        let lowercasedQuery = query.lowercased()

        let descriptor = FetchDescriptor<StoredToDoTask>(
            predicate: #Predicate {
                $0.title.localizedStandardContains(lowercasedQuery) ||
                $0.notes.localizedStandardContains(lowercasedQuery)
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toTask() }
        } catch {
            print("Failed to search tasks: \(error)")
            return []
        }
    }

    func saveTask(_ task: ToDoTask) {
        guard let context = modelContext else { return }

        let id = task.id ?? UUID().uuidString

        var descriptor = FetchDescriptor<StoredToDoTask>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.title = task.title
                existing.notes = task.notes
                existing.priorityRaw = task.priority.rawValue
                existing.statusRaw = task.status.rawValue
                existing.dueDate = task.dueDate
                existing.recurrenceRuleJSON = task.recurrenceRuleJSON()
                existing.projectId = task.projectId
                existing.labelsJSON = task.labelsJSON()
                existing.parentTaskId = task.parentTaskId
                existing.subtaskIdsJSON = task.subtaskIdsJSON()
                existing.sortOrder = task.sortOrder
                existing.updatedAt = Date()
                existing.completedAt = task.completedAt
            } else {
                // Create new
                var mutableTask = task
                mutableTask.id = id
                context.insert(mutableTask.toStoredTask())
            }

            try context.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }

    func deleteTask(_ task: ToDoTask) {
        guard let context = modelContext, let id = task.id else { return }

        // Also delete subtasks
        let subtasks = fetchSubtasks(forTask: id)
        for subtask in subtasks {
            deleteTask(subtask)
        }

        var descriptor = FetchDescriptor<StoredToDoTask>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete task: \(error)")
        }
    }

    func completeTask(_ task: ToDoTask) {
        var mutableTask = task
        mutableTask.complete()

        // If recurring, create next instance
        if let nextTask = mutableTask.creatingNextRecurrence() {
            saveTask(nextTask)
        }

        saveTask(mutableTask)
    }

    func uncompleteTask(_ task: ToDoTask) {
        var mutableTask = task
        mutableTask.uncomplete()
        saveTask(mutableTask)
    }

    // MARK: - Project Operations

    func fetchAllProjects() -> [Project] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredProject>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toProject() }
        } catch {
            print("Failed to fetch projects: \(error)")
            return []
        }
    }

    func saveProject(_ project: Project) {
        guard let context = modelContext else { return }

        let id = project.id ?? UUID().uuidString

        var descriptor = FetchDescriptor<StoredProject>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                existing.name = project.name
                existing.color = project.color
                existing.iconName = project.iconName
                existing.sortOrder = project.sortOrder
                existing.isArchived = project.isArchived
                existing.updatedAt = Date()
            } else {
                var mutableProject = project
                mutableProject.id = id
                context.insert(mutableProject.toStoredProject())
            }

            try context.save()
        } catch {
            print("Failed to save project: \(error)")
        }
    }

    func deleteProject(_ project: Project) {
        guard let context = modelContext, let id = project.id else { return }

        // Move all tasks from this project to inbox
        let tasks = fetchTasks(forProject: id)
        for task in tasks {
            var mutableTask = task
            mutableTask.projectId = nil
            saveTask(mutableTask)
        }

        var descriptor = FetchDescriptor<StoredProject>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete project: \(error)")
        }
    }

    func taskCount(forProject projectId: String?) -> Int {
        guard let context = modelContext else { return 0 }

        var descriptor: FetchDescriptor<StoredToDoTask>

        if let projectId {
            descriptor = FetchDescriptor<StoredToDoTask>(
                predicate: #Predicate {
                    $0.projectId == projectId &&
                    $0.statusRaw == "pending" &&
                    $0.parentTaskId == nil
                }
            )
        } else {
            descriptor = FetchDescriptor<StoredToDoTask>(
                predicate: #Predicate {
                    $0.projectId == nil &&
                    $0.statusRaw == "pending" &&
                    $0.parentTaskId == nil
                }
            )
        }

        do {
            return try context.fetchCount(descriptor)
        } catch {
            return 0
        }
    }

    // MARK: - Habit Operations

    func fetchAllHabits() -> [Habit] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredHabit>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.createdAt)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toHabit() }
        } catch {
            print("Failed to fetch habits: \(error)")
            return []
        }
    }

    func saveHabit(_ habit: Habit) {
        guard let context = modelContext else { return }

        let id = habit.id ?? UUID().uuidString

        var descriptor = FetchDescriptor<StoredHabit>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                existing.name = habit.name
                existing.notes = habit.notes
                existing.color = habit.color
                existing.iconName = habit.iconName
                existing.recurrenceRuleJSON = habit.recurrenceRuleJSON() ?? ""
                existing.targetPerPeriod = habit.targetPerPeriod
                existing.streakCurrent = habit.streakCurrent
                existing.streakBest = habit.streakBest
                existing.completionDatesJSON = habit.completionDatesJSON()
                existing.updatedAt = Date()
                existing.isArchived = habit.isArchived
            } else {
                var mutableHabit = habit
                mutableHabit.id = id
                context.insert(mutableHabit.toStoredHabit())
            }

            try context.save()
        } catch {
            print("Failed to save habit: \(error)")
        }
    }

    func deleteHabit(_ habit: Habit) {
        guard let context = modelContext, let id = habit.id else { return }

        var descriptor = FetchDescriptor<StoredHabit>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete habit: \(error)")
        }
    }

    func markHabitCompleted(_ habit: Habit) {
        var mutableHabit = habit
        mutableHabit.markCompleted()
        saveHabit(mutableHabit)
    }

    func unmarkHabitCompletedToday(_ habit: Habit) {
        var mutableHabit = habit
        mutableHabit.unmarkCompletedToday()
        saveHabit(mutableHabit)
    }
}
