import SwiftUI

struct UpcomingView: View {
    @State private var tasks: [ToDoTask] = []
    @State private var selectedTask: ToDoTask?
    @State private var daysToShow = 7

    private var groupedTasks: [(date: Date, tasks: [ToDoTask])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: tasks) { task -> Date in
            guard let dueDate = task.dueDate else {
                return Date.distantFuture
            }
            return calendar.startOfDay(for: dueDate)
        }

        return grouped
            .sorted { $0.key < $1.key }
            .filter { $0.key != Date.distantFuture }
            .map { (date: $0.key, tasks: $0.value) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                // Range picker
                Picker("Days", selection: $daysToShow) {
                    Text("7 days").tag(7)
                    Text("14 days").tag(14)
                    Text("30 days").tag(30)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Grouped tasks
                if groupedTasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.5))

                        Text("No upcoming tasks")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Tasks with due dates in the next \(daysToShow) days will appear here")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 48)
                    .padding(.horizontal)
                } else {
                    ForEach(groupedTasks, id: \.date) { group in
                        DateGroupedTaskList(
                            date: group.date,
                            tasks: group.tasks,
                            onToggle: { task in toggleTask(task) },
                            onTap: { task in selectedTask = task }
                        )
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadTasks()
        }
        .onChange(of: daysToShow) { _, _ in
            loadTasks()
        }
        .refreshable {
            loadTasks()
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
        tasks = ToDoStore.shared.fetchUpcomingTasks(days: daysToShow)
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

struct DateGroupedTaskList: View {
    let date: Date
    let tasks: [ToDoTask]
    let onToggle: (ToDoTask) -> Void
    let onTap: (ToDoTask) -> Void

    private var dateLabel: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }

    private var isWeekend: Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7  // Sunday or Saturday
    }

    var body: some View {
        Section {
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
        } header: {
            HStack(spacing: 8) {
                Text(dateLabel)
                    .font(.headline)
                    .foregroundStyle(.white)

                if isWeekend {
                    Text("Weekend")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                        )
                }

                Spacer()

                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
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

        UpcomingView()
    }
}
