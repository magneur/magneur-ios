import SwiftUI

struct SubtaskListView: View {
    let parentTask: ToDoTask
    @Binding var subtasks: [ToDoTask]
    let onSubtaskToggle: (ToDoTask) -> Void
    let onAddSubtask: (String) -> Void
    let onDeleteSubtask: (ToDoTask) -> Void

    @State private var newSubtaskTitle = ""
    @State private var isAddingSubtask = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Existing subtasks
            ForEach(subtasks) { subtask in
                SubtaskRow(
                    subtask: subtask,
                    onToggle: { onSubtaskToggle(subtask) },
                    onDelete: { onDeleteSubtask(subtask) }
                )

                if subtask.id != subtasks.last?.id {
                    Divider()
                        .padding(.leading, 36)
                }
            }

            // Add subtask row
            if isAddingSubtask {
                HStack(spacing: 12) {
                    Circle()
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 20, height: 20)

                    TextField("Subtask title", text: $newSubtaskTitle)
                        .font(.subheadline)
                        .focused($isInputFocused)
                        .onSubmit {
                            addSubtask()
                        }

                    Button {
                        addSubtask()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    .disabled(newSubtaskTitle.isEmpty)

                    Button {
                        cancelAddSubtask()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)
            } else {
                Button {
                    withAnimation {
                        isAddingSubtask = true
                        isInputFocused = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.blue)
                            .frame(width: 20, height: 20)

                        Text("Add subtask")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func addSubtask() {
        let title = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        onAddSubtask(title)
        newSubtaskTitle = ""
        // Keep input open for rapid entry
    }

    private func cancelAddSubtask() {
        withAnimation {
            newSubtaskTitle = ""
            isAddingSubtask = false
            isInputFocused = false
        }
    }
}

struct SubtaskRow: View {
    let subtask: ToDoTask
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteButton = false

    var body: some View {
        HStack(spacing: 12) {
            // Mini checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            subtask.isCompleted ? Color.green : Color.secondary.opacity(0.3),
                            lineWidth: 1.5
                        )
                        .frame(width: 20, height: 20)

                    if subtask.isCompleted {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 16, height: 16)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Title
            Text(subtask.title)
                .font(.subheadline)
                .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                .strikethrough(subtask.isCompleted, color: .secondary)
                .lineLimit(2)

            Spacer()

            // Delete button (shown on tap or swipe)
            if showDeleteButton {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showDeleteButton.toggle()
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    List {
        Section("Subtasks") {
            SubtaskListView(
                parentTask: ToDoTask(id: "1", title: "Parent Task"),
                subtasks: .constant([
                    ToDoTask(id: "s1", title: "First subtask", status: .completed),
                    ToDoTask(id: "s2", title: "Second subtask"),
                    ToDoTask(id: "s3", title: "Third subtask with a really long title that wraps"),
                ]),
                onSubtaskToggle: { _ in },
                onAddSubtask: { _ in },
                onDeleteSubtask: { _ in }
            )
        }
    }
}
