import SwiftUI

struct TaskSearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [ToDoTask] = []
    @State private var selectedTask: ToDoTask?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.6))

                TextField("Search tasks...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        performSearch()
                    }
                    .onChange(of: searchText) { _, _ in
                        performSearch()
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
            )
            .padding()

            // Results
            if searchText.isEmpty {
                // Empty state - suggestions
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.3))

                    Text("Search all tasks")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Search by title or notes content")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if searchResults.isEmpty {
                // No results
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.3))

                    Text("No results found")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Try different keywords")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                // Results list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchResults) { task in
                            SearchResultRow(
                                task: task,
                                searchText: searchText,
                                onToggle: { toggleTask(task) },
                                onTap: { selectedTask = task }
                            )

                            if task.id != searchResults.last?.id {
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
        }
        .onAppear {
            isSearchFocused = true
        }
        .sheet(item: $selectedTask) { task in
            NavigationStack {
                TaskDetailView(
                    task: task,
                    onSave: { updatedTask in
                        ToDoStore.shared.saveTask(updatedTask)
                        performSearch()
                    },
                    onDelete: {
                        ToDoStore.shared.deleteTask(task)
                        performSearch()
                    }
                )
            }
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        searchResults = ToDoStore.shared.searchTasks(query: searchText)
    }

    private func toggleTask(_ task: ToDoTask) {
        if task.isCompleted {
            ToDoStore.shared.uncompleteTask(task)
        } else {
            ToDoStore.shared.completeTask(task)
        }
        performSearch()
    }
}

struct SearchResultRow: View {
    let task: ToDoTask
    let searchText: String
    let onToggle: () -> Void
    let onTap: () -> Void

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
                // Title with highlighted text
                HighlightedText(text: task.title, highlight: searchText)
                    .font(.body)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .lineLimit(2)

                // Notes preview with highlight
                if !task.notes.isEmpty && task.notes.localizedCaseInsensitiveContains(searchText) {
                    HighlightedText(text: task.notes, highlight: searchText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Meta row
                HStack(spacing: 8) {
                    DueDateBadge(task: task)
                    PriorityBadge(priority: task.priority)

                    if !task.labels.isEmpty {
                        Text("#\(task.labels.first!)")
                            .font(.caption2)
                            .foregroundStyle(.indigo)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct HighlightedText: View {
    let text: String
    let highlight: String

    var body: some View {
        if highlight.isEmpty {
            Text(text)
        } else {
            Text(attributedString)
        }
    }

    private var attributedString: AttributedString {
        var attributed = AttributedString(text)

        let lowercasedText = text.lowercased()
        let lowercasedHighlight = highlight.lowercased()

        var searchRange = lowercasedText.startIndex..<lowercasedText.endIndex

        while let range = lowercasedText.range(of: lowercasedHighlight, range: searchRange) {
            let startIndex = attributed.index(attributed.startIndex, offsetByCharacters: lowercasedText.distance(from: lowercasedText.startIndex, to: range.lowerBound))
            let endIndex = attributed.index(startIndex, offsetByCharacters: highlight.count)

            if startIndex < attributed.endIndex && endIndex <= attributed.endIndex {
                attributed[startIndex..<endIndex].backgroundColor = .yellow.opacity(0.3)
                attributed[startIndex..<endIndex].foregroundColor = .primary
            }

            searchRange = range.upperBound..<lowercasedText.endIndex
        }

        return attributed
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

        TaskSearchView()
    }
}
