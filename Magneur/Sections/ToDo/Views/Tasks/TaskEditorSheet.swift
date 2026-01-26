import SwiftUI

struct TaskEditorSheet: View {
    @Binding var isPresented: Bool
    let projectId: String?
    let onSave: (ToDoTask) -> Void

    @State private var inputText = ""
    @State private var parsedTask: TaskInputParser.ParsedTask?
    @State private var showAdvancedOptions = false

    // Manual overrides (when user wants to tweak parsed values)
    @State private var manualDueDate: Date?
    @State private var manualPriority: TaskPriority = .p4
    @State private var manualLabels: [String] = []
    @State private var manualRecurrence: TaskRecurrenceRule?
    @State private var hasManualOverrides = false

    private let parser = TaskInputParser()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Natural language input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.indigo)
                        Text("Natural Language Input")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    TextField("e.g., Buy milk tomorrow 3pm p1 #shopping", text: $inputText, axis: .vertical)
                        .font(.body)
                        .lineLimit(3...6)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .onChange(of: inputText) { _, newValue in
                            if !hasManualOverrides {
                                parsedTask = parser.parse(newValue)
                                updateFromParsed()
                            }
                        }
                }
                .padding()

                // Parsed preview
                if let parsed = parsedTask, !inputText.isEmpty {
                    ParsedTaskPreview(parsed: parsed)
                        .padding(.horizontal)
                }

                Divider()
                    .padding(.vertical, 8)

                // Advanced options toggle
                Button {
                    withAnimation {
                        showAdvancedOptions.toggle()
                        if showAdvancedOptions {
                            hasManualOverrides = true
                        }
                    }
                } label: {
                    HStack {
                        Text("Manual Options")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .buttonStyle(.plain)

                if showAdvancedOptions {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Due date
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Due Date")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                DueDatePicker(dueDate: $manualDueDate)
                            }

                            // Priority
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Priority")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                PriorityPicker(priority: $manualPriority)
                            }

                            // Recurrence
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Repeat")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                RecurrencePicker(recurrenceRule: $manualRecurrence)
                            }

                            // Labels
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Labels")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                LabelInput(labels: $manualLabels)
                            }
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTask()
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func updateFromParsed() {
        guard let parsed = parsedTask else { return }
        manualDueDate = parsed.dueDate
        manualPriority = parsed.priority
        manualLabels = parsed.labels
        manualRecurrence = parsed.recurrenceRule
    }

    private func saveTask() {
        let title: String
        let dueDate: Date?
        let priority: TaskPriority
        let labels: [String]
        let recurrence: TaskRecurrenceRule?

        if hasManualOverrides {
            // Use manual values
            title = parsedTask?.title ?? inputText.trimmingCharacters(in: .whitespaces)
            dueDate = manualDueDate
            priority = manualPriority
            labels = manualLabels
            recurrence = manualRecurrence
        } else if let parsed = parsedTask {
            // Use parsed values
            title = parsed.title
            dueDate = parsed.dueDate
            priority = parsed.priority
            labels = parsed.labels
            recurrence = parsed.recurrenceRule
        } else {
            title = inputText.trimmingCharacters(in: .whitespaces)
            dueDate = nil
            priority = .p4
            labels = []
            recurrence = nil
        }

        let newTask = ToDoTask(
            title: title,
            priority: priority,
            dueDate: dueDate,
            recurrenceRule: recurrence,
            projectId: projectId,
            labels: labels
        )

        onSave(newTask)
        isPresented = false
    }
}

struct ParsedTaskPreview: View {
    let parsed: TaskInputParser.ParsedTask

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                // Title
                Text(parsed.title.isEmpty ? "..." : parsed.title)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()

                // Priority
                if parsed.priority != .p4 {
                    Text(parsed.priority.displayName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(hex: parsed.priority.color) ?? .gray)
                        )
                }
            }

            HStack(spacing: 12) {
                // Due date
                if let date = parsed.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(date, style: .date)
                            .font(.caption)
                    }
                    .foregroundStyle(.green)
                }

                // Recurrence
                if let rule = parsed.recurrenceRule {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.caption2)
                        Text(rule.displayString)
                            .font(.caption)
                    }
                    .foregroundStyle(.indigo)
                }

                // Labels
                ForEach(parsed.labels, id: \.self) { label in
                    Text("#\(label)")
                        .font(.caption)
                        .foregroundStyle(.purple)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
                .strokeBorder(Color.indigo.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    TaskEditorSheet(
        isPresented: .constant(true),
        projectId: nil,
        onSave: { _ in }
    )
}
