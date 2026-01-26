import SwiftUI

struct HabitEditorView: View {
    let habit: Habit?  // nil = creating new
    let onSave: (Habit) -> Void
    let onDelete: (() -> Void)?

    @State private var name: String
    @State private var notes: String
    @State private var selectedColor: String
    @State private var selectedIcon: String
    @State private var frequency: TaskRecurrenceRule.Frequency
    @State private var targetPerPeriod: Int
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(habit: Habit?, onSave: @escaping (Habit) -> Void, onDelete: (() -> Void)?) {
        self.habit = habit
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: habit?.name ?? "")
        _notes = State(initialValue: habit?.notes ?? "")
        _selectedColor = State(initialValue: habit?.color ?? "#5856D6")
        _selectedIcon = State(initialValue: habit?.iconName ?? "checkmark.circle.fill")
        _frequency = State(initialValue: habit?.recurrenceRule.frequency ?? .daily)
        _targetPerPeriod = State(initialValue: habit?.targetPerPeriod ?? 1)
    }

    private var isEditing: Bool {
        habit != nil
    }

    var body: some View {
        NavigationStack {
            List {
                // Preview
                Section {
                    HStack {
                        Spacer()
                        HabitPreview(name: name, color: selectedColor, icon: selectedIcon)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                // Name
                Section("Habit Name") {
                    TextField("Enter habit name", text: $name)
                }

                // Notes
                Section("Notes (optional)") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                // Frequency
                Section("How often?") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(TaskRecurrenceRule.Frequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)

                    Stepper("Target: \(targetPerPeriod) time\(targetPerPeriod == 1 ? "" : "s") per \(frequencyUnit)", value: $targetPerPeriod, in: 1...10)
                }

                // Color picker
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Project.availableColors, id: \.hex) { colorOption in
                            ColorPickerButton(
                                color: colorOption.hex,
                                isSelected: selectedColor == colorOption.hex
                            ) {
                                selectedColor = colorOption.hex
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Icon picker
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Habit.availableIcons, id: \.self) { icon in
                            IconPickerButton(
                                icon: icon,
                                color: selectedColor,
                                isSelected: selectedIcon == icon
                            ) {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Delete
                if isEditing, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Habit")
                            }
                        }
                    } footer: {
                        Text("This will permanently delete this habit and all completion history.")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .confirmationDialog("Delete Habit", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete this habit and all completion history.")
            }
        }
    }

    private var frequencyUnit: String {
        switch frequency {
        case .daily: return "day"
        case .weekly: return "week"
        case .monthly: return "month"
        case .yearly: return "year"
        }
    }

    private func save() {
        var savedHabit = habit ?? Habit(name: "")
        savedHabit.name = name.trimmingCharacters(in: .whitespaces)
        savedHabit.notes = notes.trimmingCharacters(in: .whitespaces)
        savedHabit.color = selectedColor
        savedHabit.iconName = selectedIcon
        savedHabit.recurrenceRule = TaskRecurrenceRule(frequency: frequency)
        savedHabit.targetPerPeriod = targetPerPeriod
        savedHabit.updatedAt = Date()

        onSave(savedHabit)
        dismiss()
    }
}

struct HabitPreview: View {
    let name: String
    let color: String
    let icon: String

    private var displayColor: Color {
        Color(hex: color) ?? .indigo
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(displayColor.opacity(0.2))
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(displayColor)
            }

            Text(name.isEmpty ? "Habit Name" : name)
                .font(.headline)
                .foregroundStyle(name.isEmpty ? .secondary : .primary)
        }
        .padding(.vertical)
    }
}

#Preview {
    HabitEditorView(
        habit: nil,
        onSave: { _ in },
        onDelete: nil
    )
}
