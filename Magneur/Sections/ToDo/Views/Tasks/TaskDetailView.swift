import SwiftUI

struct TaskDetailView: View {
    @State var task: ToDoTask
    let onSave: (ToDoTask) -> Void
    let onDelete: () -> Void

    @State private var subtasks: [ToDoTask] = []
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            // Title Section
            Section {
                TextField("Task title", text: $task.title, axis: .vertical)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            // Notes Section
            Section("Notes") {
                TextField("Add notes...", text: $task.notes, axis: .vertical)
                    .lineLimit(5...10)
            }

            // Due Date Section
            Section("Due Date") {
                DueDatePicker(dueDate: $task.dueDate)
            }

            // Priority Section
            Section("Priority") {
                PriorityPicker(priority: $task.priority)
            }

            // Recurrence Section
            Section("Repeat") {
                RecurrencePicker(recurrenceRule: $task.recurrenceRule)
            }

            // Labels Section
            Section("Labels") {
                LabelInput(labels: $task.labels)
            }

            // Subtasks Section
            Section {
                SubtaskListView(
                    parentTask: task,
                    subtasks: $subtasks,
                    onSubtaskToggle: { subtask in
                        toggleSubtask(subtask)
                    },
                    onAddSubtask: { title in
                        addSubtask(title: title)
                    },
                    onDeleteSubtask: { subtask in
                        deleteSubtask(subtask)
                    }
                )
            } header: {
                HStack {
                    Text("Subtasks")
                    Spacer()
                    if !subtasks.isEmpty {
                        let completed = subtasks.filter(\.isCompleted).count
                        Text("\(completed)/\(subtasks.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Delete Section
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Task")
                    }
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(task.title.isEmpty)
            }
        }
        .confirmationDialog("Delete Task", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete this task and all its subtasks.")
        }
        .onAppear {
            loadSubtasks()
        }
    }

    private func loadSubtasks() {
        guard let taskId = task.id else { return }
        subtasks = ToDoStore.shared.fetchSubtasks(forTask: taskId)
    }

    private func save() {
        // Save subtasks first
        for subtask in subtasks {
            ToDoStore.shared.saveTask(subtask)
        }

        // Update subtask IDs on parent task
        task.subtaskIds = subtasks.compactMap(\.id)

        onSave(task)
        dismiss()
    }

    private func toggleSubtask(_ subtask: ToDoTask) {
        guard let index = subtasks.firstIndex(where: { $0.id == subtask.id }) else { return }

        if subtasks[index].isCompleted {
            subtasks[index].uncomplete()
        } else {
            subtasks[index].complete()
        }

        ToDoStore.shared.saveTask(subtasks[index])
    }

    private func addSubtask(title: String) {
        let newSubtask = ToDoTask(
            id: UUID().uuidString,
            title: title,
            parentTaskId: task.id,
            sortOrder: subtasks.count
        )
        subtasks.append(newSubtask)
        ToDoStore.shared.saveTask(newSubtask)
    }

    private func deleteSubtask(_ subtask: ToDoTask) {
        subtasks.removeAll { $0.id == subtask.id }
        ToDoStore.shared.deleteTask(subtask)
    }
}

struct RecurrencePicker: View {
    @Binding var recurrenceRule: TaskRecurrenceRule?

    private let options: [(title: String, rule: TaskRecurrenceRule?)] = [
        ("None", nil),
        ("Daily", .daily),
        ("Weekly", .weekly),
        ("Monthly", .monthly),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.title) { option in
                let isSelected = (option.rule == nil && recurrenceRule == nil) ||
                                 (option.rule != nil && recurrenceRule?.frequency == option.rule?.frequency)

                Button {
                    recurrenceRule = option.rule
                } label: {
                    Text(option.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.indigo : Color(.systemGray5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            task: ToDoTask(title: "Sample Task", notes: "Some notes here", priority: .p2),
            onSave: { _ in },
            onDelete: {}
        )
    }
}
