import SwiftUI

struct QuickCaptureView: View {
    let onTaskCreated: (ToDoTask) -> Void

    @State private var inputText = ""
    @State private var showParsedPreview = false
    @FocusState private var isInputFocused: Bool

    private let parser = TaskInputParser()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Input field
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white.opacity(0.7))

                    TextField("Add task... (e.g., Buy milk p1 #shopping)", text: $inputText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .focused($isInputFocused)
                        .onSubmit {
                            createTask()
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )

                // Submit button
                if !inputText.isEmpty {
                    Button {
                        createTask()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)

            // Inline parsed preview
            if !inputText.isEmpty {
                let parsed = parser.parse(inputText)

                HStack(spacing: 8) {
                    if parsed.dueDate != nil || parsed.priority != .p4 || !parsed.labels.isEmpty || parsed.recurrenceRule != nil {
                        HStack(spacing: 6) {
                            // Due date
                            if let date = parsed.dueDate {
                                HStack(spacing: 2) {
                                    Image(systemName: "calendar")
                                        .font(.caption2)
                                    Text(formatDate(date))
                                        .font(.caption2)
                                }
                                .foregroundStyle(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.2))
                                )
                            }

                            // Priority
                            if parsed.priority != .p4 {
                                Text(parsed.priority.displayName)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: parsed.priority.color) ?? .gray)
                                    )
                            }

                            // Recurrence
                            if let rule = parsed.recurrenceRule {
                                HStack(spacing: 2) {
                                    Image(systemName: "repeat")
                                        .font(.caption2)
                                    Text(rule.displayString)
                                        .font(.caption2)
                                }
                                .foregroundStyle(.purple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color.purple.opacity(0.2))
                                )
                            }

                            // Labels
                            ForEach(parsed.labels.prefix(2), id: \.self) { label in
                                Text("#\(label)")
                                    .font(.caption2)
                                    .foregroundStyle(.indigo)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color.indigo.opacity(0.2))
                                    )
                            }
                        }
                    }

                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.15), value: inputText)
            }
        }
    }

    private func createTask() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let parsed = parser.parse(inputText)

        var dueDate = parsed.dueDate
        // Default to today if no date specified
        if dueDate == nil {
            dueDate = Calendar.current.startOfDay(for: Date())
        }

        let task = ToDoTask(
            title: parsed.title,
            priority: parsed.priority,
            dueDate: dueDate,
            recurrenceRule: parsed.recurrenceRule,
            labels: parsed.labels
        )

        onTaskCreated(task)

        // Reset input
        inputText = ""
        isInputFocused = false
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
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

        VStack {
            QuickCaptureView(onTaskCreated: { _ in })
                .padding()
            Spacer()
        }
    }
}
