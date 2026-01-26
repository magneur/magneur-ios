import SwiftUI

struct ProjectDetailView: View {
    let project: Project?  // nil = Inbox
    let onProjectUpdated: () -> Void

    @State private var tasks: [ToDoTask] = []
    @State private var showAddTask = false
    @State private var selectedTask: ToDoTask?
    @State private var showEditProject = false
    @Environment(\.dismiss) private var dismiss

    private var projectName: String {
        project?.name ?? "Inbox"
    }

    private var projectColor: Color {
        if let hex = project?.color {
            return Color(hex: hex) ?? .blue
        }
        return .blue
    }

    private var pendingTasks: [ToDoTask] {
        tasks.filter { !$0.isCompleted }
    }

    private var completedTasks: [ToDoTask] {
        tasks.filter(\.isCompleted)
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [projectColor.opacity(0.8), projectColor.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16) {
                    // Pending tasks
                    if !pendingTasks.isEmpty {
                        TaskListSection(
                            tasks: pendingTasks,
                            onToggle: { toggleTask($0) },
                            onTap: { selectedTask = $0 }
                        )
                    }

                    // Empty state
                    if pendingTasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundStyle(.white.opacity(0.5))

                            Text("No pending tasks")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.7))

                            Button {
                                showAddTask = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Task")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                            }
                        }
                        .padding(.vertical, 48)
                    }

                    // Completed tasks
                    if !completedTasks.isEmpty {
                        DisclosureGroup {
                            TaskListSection(
                                tasks: completedTasks,
                                onToggle: { toggleTask($0) },
                                onTap: { selectedTask = $0 }
                            )
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Completed")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("\(completedTasks.count)")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .tint(.white)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(projectName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }

                    if project != nil {
                        Button {
                            showEditProject = true
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .foregroundStyle(.white)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            loadTasks()
        }
        .refreshable {
            loadTasks()
        }
        .sheet(isPresented: $showAddTask) {
            TaskEditorSheet(
                isPresented: $showAddTask,
                projectId: project?.id,
                onSave: { task in
                    ToDoStore.shared.saveTask(task)
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
        .sheet(isPresented: $showEditProject) {
            if let project {
                ProjectEditorView(
                    project: project,
                    onSave: { updatedProject in
                        ToDoStore.shared.saveProject(updatedProject)
                        onProjectUpdated()
                    },
                    onDelete: {
                        ToDoStore.shared.deleteProject(project)
                        onProjectUpdated()
                        dismiss()
                    }
                )
            }
        }
    }

    private func loadTasks() {
        tasks = ToDoStore.shared.fetchTasks(forProject: project?.id)
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

struct TaskListSection: View {
    let tasks: [ToDoTask]
    let onToggle: (ToDoTask) -> Void
    let onTap: (ToDoTask) -> Void

    var body: some View {
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

#Preview {
    NavigationStack {
        ProjectDetailView(
            project: Project(name: "Work", color: "#FF9500", iconName: "briefcase.fill"),
            onProjectUpdated: {}
        )
    }
}
