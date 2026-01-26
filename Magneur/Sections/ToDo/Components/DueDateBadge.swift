import SwiftUI

struct DueDateBadge: View {
    let task: ToDoTask

    private var textColor: Color {
        if task.isOverdue {
            return .red
        } else if task.isDueToday {
            return .green
        } else if task.isDueTomorrow {
            return .orange
        }
        return .secondary
    }

    private var icon: String {
        if task.isRecurring {
            return "repeat"
        } else if task.isOverdue {
            return "exclamationmark.triangle.fill"
        }
        return "calendar"
    }

    var body: some View {
        if let dateText = task.formattedDueDate {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)

                Text(dateText)
                    .font(.caption)
            }
            .foregroundStyle(textColor)
        }
    }
}

struct DueDatePicker: View {
    @Binding var dueDate: Date?
    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quick options
            HStack(spacing: 8) {
                QuickDateButton(title: "Today", date: Date()) { date in
                    dueDate = Calendar.current.startOfDay(for: date)
                }

                QuickDateButton(title: "Tomorrow", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) { date in
                    dueDate = Calendar.current.startOfDay(for: date)
                }

                QuickDateButton(title: "Next Week", date: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!) { date in
                    dueDate = Calendar.current.startOfDay(for: date)
                }
            }

            // Current selection or picker trigger
            Button {
                selectedDate = dueDate ?? Date()
                showDatePicker.toggle()
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)

                    if let date = dueDate {
                        Text(date, style: .date)
                            .foregroundStyle(.primary)

                        Spacer()

                        Button {
                            dueDate = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Pick a date")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    DatePicker("Due Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .padding()
                        .navigationTitle("Select Date")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    showDatePicker = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    dueDate = selectedDate
                                    showDatePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
        }
    }
}

struct QuickDateButton: View {
    let title: String
    let date: Date
    let onSelect: (Date) -> Void

    var body: some View {
        Button {
            onSelect(date)
        } label: {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.8))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        DueDatePicker(dueDate: .constant(nil))
        DueDatePicker(dueDate: .constant(Date()))
    }
    .padding()
}
