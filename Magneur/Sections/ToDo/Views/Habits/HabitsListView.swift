import SwiftUI

struct HabitsListView: View {
    @State private var habits: [Habit] = []
    @State private var showAddHabit = false
    @State private var selectedHabit: Habit?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Header with add button
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Habits")
                            .font(.headline)
                            .foregroundStyle(.white)

                        let completed = habits.filter(\.isCompletedToday).count
                        Text("\(completed) of \(habits.count) completed today")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    Button {
                        showAddHabit = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("New")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                }
                .padding(.horizontal)

                // Habits list
                if habits.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "flame")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.5))

                        Text("No habits yet")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Create habits to build positive routines")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.vertical, 48)
                } else {
                    VStack(spacing: 0) {
                        ForEach(habits) { habit in
                            HabitRowView(
                                habit: habit,
                                onToggle: { toggleHabit(habit) },
                                onTap: { selectedHabit = habit }
                            )

                            if habit.id != habits.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground).opacity(0.6))
                    )
                    .padding(.horizontal)
                }

                // Stats card
                if !habits.isEmpty {
                    HabitStatsCard(habits: habits)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadHabits()
        }
        .refreshable {
            loadHabits()
        }
        .sheet(isPresented: $showAddHabit) {
            HabitEditorView(
                habit: nil,
                onSave: { habit in
                    ToDoStore.shared.saveHabit(habit)
                    loadHabits()
                },
                onDelete: nil
            )
        }
        .sheet(item: $selectedHabit) { habit in
            NavigationStack {
                HabitCalendarView(habit: habit, onHabitUpdated: { loadHabits() })
            }
        }
    }

    private func loadHabits() {
        habits = ToDoStore.shared.fetchAllHabits()
    }

    private func toggleHabit(_ habit: Habit) {
        if habit.isCompletedToday {
            ToDoStore.shared.unmarkHabitCompletedToday(habit)
        } else {
            ToDoStore.shared.markHabitCompleted(habit)
        }
        loadHabits()
    }
}

struct HabitStatsCard: View {
    let habits: [Habit]

    private var totalCompletedToday: Int {
        habits.filter(\.isCompletedToday).count
    }

    private var bestStreak: Int {
        habits.map(\.streakBest).max() ?? 0
    }

    private var activeStreaks: Int {
        habits.filter { $0.streakCurrent > 0 }.count
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Stats")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                HabitStatItem(value: "\(totalCompletedToday)/\(habits.count)", label: "Today", icon: "checkmark.circle.fill", color: .green)
                HabitStatItem(value: "\(activeStreaks)", label: "Active Streaks", icon: "flame.fill", color: .orange)
                HabitStatItem(value: "\(bestStreak)", label: "Best Streak", icon: "trophy.fill", color: .yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct HabitStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
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

        HabitsListView()
    }
}
