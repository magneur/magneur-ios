import SwiftUI

struct HabitCalendarView: View {
    @State var habit: Habit
    let onHabitUpdated: () -> Void

    @State private var showEditHabit = false
    @Environment(\.dismiss) private var dismiss

    private var habitColor: Color {
        Color(hex: habit.color) ?? .indigo
    }

    private var completionRate: Double {
        HabitStreakCalculator.completionRate(completionDates: habit.completionDates, days: 30)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                HabitHeaderCard(habit: habit, onToggle: toggleToday)

                // Stats row
                HStack(spacing: 16) {
                    HabitStatCard(
                        title: "Current Streak",
                        value: "\(habit.streakCurrent)",
                        subtitle: "days",
                        icon: "flame.fill",
                        color: .orange
                    )

                    HabitStatCard(
                        title: "Best Streak",
                        value: "\(habit.streakBest)",
                        subtitle: "days",
                        icon: "trophy.fill",
                        color: .yellow
                    )

                    HabitStatCard(
                        title: "30-Day Rate",
                        value: "\(Int(completionRate * 100))%",
                        subtitle: "completed",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                }
                .padding(.horizontal)

                // Calendar grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Completion History")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    GitHubStyleCalendar(habit: habit)
                        .padding(.horizontal)
                }

                // Target info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target")
                        .font(.headline)
                        .foregroundStyle(.white)

                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(habitColor)

                        Text(habit.targetDescription)
                            .foregroundStyle(.white.opacity(0.8))

                        Spacer()

                        Text("\(habit.completionsThisPeriod)/\(habit.targetPerPeriod)")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding(.horizontal)

                // Notes
                if !habit.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(habit.notes)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(
                colors: [habitColor.opacity(0.8), habitColor.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditHabit = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.white)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEditHabit) {
            HabitEditorView(
                habit: habit,
                onSave: { updatedHabit in
                    ToDoStore.shared.saveHabit(updatedHabit)
                    habit = updatedHabit
                    onHabitUpdated()
                },
                onDelete: {
                    ToDoStore.shared.deleteHabit(habit)
                    onHabitUpdated()
                    dismiss()
                }
            )
        }
    }

    private func toggleToday() {
        if habit.isCompletedToday {
            ToDoStore.shared.unmarkHabitCompletedToday(habit)
        } else {
            ToDoStore.shared.markHabitCompleted(habit)
        }
        // Refresh habit
        habit = ToDoStore.shared.fetchAllHabits().first { $0.id == habit.id } ?? habit
        onHabitUpdated()
    }
}

struct HabitHeaderCard: View {
    let habit: Habit
    let onToggle: () -> Void

    private var habitColor: Color {
        Color(hex: habit.color) ?? .indigo
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 64, height: 64)

                Image(systemName: habit.iconName)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.isCompletedToday ? "Completed today!" : "Not yet completed")
                    .font(.headline)
                    .foregroundStyle(.white)

                if habit.streakCurrent > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                        Text("\(habit.streakCurrent) day streak")
                            .font(.caption)
                    }
                    .foregroundStyle(.orange)
                }
            }

            Spacer()

            // Toggle button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(habit.isCompletedToday ? Color.green : Color.white.opacity(0.2))
                        .frame(width: 56, height: 56)

                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: 52, height: 52)
                    }
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: habit.isCompletedToday)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct HabitStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct GitHubStyleCalendar: View {
    let habit: Habit

    private let weeks = HabitStreakCalculator.calendarGridDates(weeks: 12)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    private var habitColor: Color {
        Color(hex: habit.color) ?? .indigo
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Day labels
            HStack(spacing: 4) {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 16, height: 16)
                }
            }

            // Calendar grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(weeks.indices, id: \.self) { weekIndex in
                        VStack(spacing: 4) {
                            ForEach(weeks[weekIndex], id: \.self) { date in
                                CalendarCell(
                                    date: date,
                                    status: habit.completionStatus(for: date),
                                    color: habitColor
                                )
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 12) {
                LegendItem(color: habitColor.opacity(0.3), label: "Missed")
                LegendItem(color: habitColor, label: "Completed")
                LegendItem(color: Color.white.opacity(0.1), label: "Future")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct CalendarCell: View {
    let date: Date
    let status: HabitCompletionStatus
    let color: Color

    private var cellColor: Color {
        switch status {
        case .completed:
            return color
        case .missed:
            return color.opacity(0.2)
        case .pending:
            return color.opacity(0.3)
        case .future:
            return Color.white.opacity(0.05)
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(cellColor)
            .frame(width: 16, height: 16)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    NavigationStack {
        HabitCalendarView(
            habit: Habit(
                id: "1",
                name: "Exercise",
                color: "#FF9500",
                iconName: "figure.run",
                recurrenceRule: .daily,
                streakCurrent: 7,
                streakBest: 14,
                completionDates: (0..<30).compactMap { offset -> Date? in
                    if offset % 3 == 0 { return nil }  // Skip some days
                    return Calendar.current.date(byAdding: .day, value: -offset, to: Date())
                }
            ),
            onHabitUpdated: {}
        )
    }
}
