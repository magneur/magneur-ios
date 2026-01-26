import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onToggle: () -> Void
    let onTap: () -> Void

    private var habitColor: Color {
        Color(hex: habit.color) ?? .indigo
    }

    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(habitColor, lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if habit.isCompletedToday {
                        Circle()
                            .fill(habitColor)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: habit.isCompletedToday)

            // Icon
            ZStack {
                Circle()
                    .fill(habitColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: habit.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(habitColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                    .foregroundStyle(.primary)

                Text(habit.targetDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Streak badge
            if habit.streakCurrent > 0 {
                StreakBadge(streak: habit.streakCurrent)
            }

            // Chevron
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

struct StreakBadge: View {
    let streak: Int

    private var badgeColor: Color {
        if streak >= 30 {
            return .purple
        } else if streak >= 14 {
            return .orange
        } else if streak >= 7 {
            return .yellow
        }
        return .green
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption2)

            Text("\(streak)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(badgeColor)
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        HabitRowView(
            habit: Habit(
                name: "Exercise",
                color: "#FF9500",
                iconName: "figure.run",
                recurrenceRule: .daily,
                streakCurrent: 7
            ),
            onToggle: {},
            onTap: {}
        )

        Divider()

        HabitRowView(
            habit: Habit(
                name: "Read",
                color: "#5856D6",
                iconName: "book.fill",
                recurrenceRule: .daily,
                streakCurrent: 21,
                completionDates: [Date()]
            ),
            onToggle: {},
            onTap: {}
        )

        Divider()

        HabitRowView(
            habit: Habit(
                name: "Meditate",
                color: "#34C759",
                iconName: "brain.head.profile",
                recurrenceRule: .daily,
                streakCurrent: 0
            ),
            onToggle: {},
            onTap: {}
        )
    }
    .background(Color(.systemBackground))
}
