import SwiftUI

struct TodayView: View {
    @State private var tasks: [ToDoTask] = []
    @State private var showAddTask = false
    @State private var selectedTask: ToDoTask?

    private var overdueTasks: [ToDoTask] {
        tasks.filter { $0.isOverdue && !$0.isCompleted }
    }

    private var todayTasks: [ToDoTask] {
        tasks.filter { $0.isDueToday && !$0.isCompleted }
    }

    private var completedTasks: [ToDoTask] {
        tasks.filter { $0.isCompleted && ($0.isDueToday || $0.isOverdue) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                // Quick capture
                QuickCaptureView(onTaskCreated: { task in
                    ToDoStore.shared.saveTask(task)
                    loadTasks()
                })
                .padding(.horizontal)

                // Overdue section
                if !overdueTasks.isEmpty {
                    TaskSection(
                        title: "Overdue",
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .red,
                        tasks: overdueTasks,
                        onToggle: { task in toggleTask(task) },
                        onTap: { task in selectedTask = task }
                    )
                }

                // Today section
                TaskSection(
                    title: "Today",
                    icon: "sun.max.fill",
                    iconColor: .orange,
                    tasks: todayTasks,
                    emptyMessage: "No tasks due today",
                    onToggle: { task in toggleTask(task) },
                    onTap: { task in selectedTask = task }
                )

                // Completed section
                if !completedTasks.isEmpty {
                    TaskSection(
                        title: "Completed",
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        tasks: completedTasks,
                        isCollapsible: true,
                        onToggle: { task in toggleTask(task) },
                        onTap: { task in selectedTask = task }
                    )
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadTasks()
        }
        .refreshable {
            loadTasks()
        }
        .sheet(isPresented: $showAddTask) {
            TaskEditorSheet(
                isPresented: $showAddTask,
                projectId: nil,
                onSave: { task in
                    var mutableTask = task
                    if mutableTask.dueDate == nil {
                        mutableTask.dueDate = Calendar.current.startOfDay(for: Date())
                    }
                    ToDoStore.shared.saveTask(mutableTask)
                    loadTasks()
                }
            )
        }
        .sheet(item: $selectedTask) { task in
            NavigationStack {
                TaskDetailView(
                    task: task,
                    onSave: { updatedTask in
                        ToDoStore.shared.saveTask(updatedTask)
                        loadTasks()
                    },
                    onDelete: {
                        ToDoStore.shared.deleteTask(task)
                        loadTasks()
                    }
                )
            }
        }
    }

    private func loadTasks() {
        tasks = ToDoStore.shared.fetchTodayTasks()
    }

    private func toggleTask(_ task: ToDoTask) {
        if task.isCompleted {
            ToDoStore.shared.uncompleteTask(task)
        } else {
            ToDoStore.shared.completeTask(task)
        }
        loadTasks()
    }
}

struct TaskSection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let tasks: [ToDoTask]
    var emptyMessage: String?
    var isCollapsible: Bool = false
    let onToggle: (ToDoTask) -> Void
    let onTap: (ToDoTask) -> Void

    @State private var isCollapsed = false

    var body: some View {
        Section {
            if !isCollapsed {
                if tasks.isEmpty {
                    if let message = emptyMessage {
                        HStack {
                            Spacer()
                            Text(message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 24)
                    }
                } else {
                    VStack(spacing: 0) {
                        ForEach(tasks) { task in
                            TaskRowView(
                                task: task,
                                subtasks: ToDoStore.shared.fetchSubtasks(forTask: task.id ?? ""),
                                onToggle: { onToggle(task) },
                                onTap: { onTap(task) }
                            )

                            if task.id != tasks.last?.id {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground).opacity(0.6))
                    )
                    .padding(.horizontal)
                }
            }
        } header: {
            Button {
                if isCollapsible {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)

                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(tasks.count)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )

                    Spacer()

                    if isCollapsible {
                        Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .disabled(!isCollapsible)
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        TodayView()
    }
}
