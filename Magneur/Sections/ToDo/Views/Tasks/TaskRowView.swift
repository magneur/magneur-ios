import SwiftUI

struct TaskRowView: View {
    let task: ToDoTask
    var subtasks: [ToDoTask] = []
    let onToggle: () -> Void
    var onTap: (() -> Void)?

    private var completedSubtaskCount: Int {
        subtasks.filter(\.isCompleted).count
    }

    private var hasProgress: Bool {
        !subtasks.isEmpty
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            TaskCheckbox(
                isCompleted: task.isCompleted,
                priority: task.priority,
                onToggle: onToggle
            )
            .padding(.top, 2)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .lineLimit(2)

                // Meta row
                HStack(spacing: 8) {
                    // Due date
                    DueDateBadge(task: task)

                    // Priority badge
                    PriorityBadge(priority: task.priority)

                    // Labels
                    if !task.labels.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(task.labels.prefix(2), id: \.self) { label in
                                Text("#\(label)")
                                    .font(.caption2)
                                    .foregroundStyle(.indigo)
                            }
                            if task.labels.count > 2 {
                                Text("+\(task.labels.count - 2)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // Subtask progress
                    if hasProgress {
                        SubtaskProgressBadge(completed: completedSubtaskCount, total: subtasks.count)
                    }
                }
            }

            // Chevron if tappable
            if onTap != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

struct SubtaskProgressBadge: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        HStack(spacing: 4) {
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 2)
                    .frame(width: 14, height: 14)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(-90))
            }

            Text("\(completed)/\(total)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TaskRowView(
            task: ToDoTask(title: "Buy groceries", priority: .p2, dueDate: Date(), labels: ["shopping", "urgent"]),
            subtasks: [
                ToDoTask(title: "Milk", status: .completed),
                ToDoTask(title: "Bread"),
                ToDoTask(title: "Eggs")
            ],
            onToggle: {},
            onTap: {}
        )

        Divider()

        TaskRowView(
            task: ToDoTask(title: "Completed task", status: .completed),
            onToggle: {}
        )

        Divider()

        TaskRowView(
            task: ToDoTask(title: "Overdue task", dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())),
            onToggle: {}
        )
    }
    .background(Color(.systemBackground))
}
