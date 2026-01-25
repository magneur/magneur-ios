//
//  GoalsListView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// List view showing all financial goals
struct GoalsListView: View {
    @State private var goals: [FinancialGoal] = []
    @State private var showingCreateGoal = false
    @State private var selectedGoal: FinancialGoal?

    var body: some View {
        ScrollView {
            if goals.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(goals) { goal in
                        GoalCardView(goal: goal)
                            .onTapGesture {
                                selectedGoal = goal
                            }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadGoals()
        }
        .sheet(isPresented: $showingCreateGoal) {
            GoalEditorView(goal: .savingsTarget()) {
                loadGoals()
            }
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal) {
                loadGoals()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.4))

            Text("No Goals Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text("Set financial goals to track your progress\nand stay motivated")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                showingCreateGoal = true
            } label: {
                Label("Create Goal", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding()
    }

    private func loadGoals() {
        goals = FinanceStore.shared.fetchAllGoals()
    }
}

/// Card view for individual goal
struct GoalCardView: View {
    let goal: FinancialGoal

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: goal.goalType.icon)
                    .font(.title3)
                    .foregroundStyle(goal.goalType.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.name.isEmpty ? goal.goalType.displayName : goal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(goal.goalType.displayName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                if goal.isAchieved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            // Progress bar
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.2))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(goal.isAchieved ? .green : goal.goalType.accentColor)
                            .frame(width: geometry.size.width * CGFloat(goal.progressPercentage))
                    }
                }
                .frame(height: 8)

                HStack {
                    Text(goal.formattedCurrentAmount())
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Text(goal.formattedTargetAmount())
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            // Status row
            HStack {
                Text("\(Int(goal.progressPercentage * 100))% complete")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                if let targetDate = goal.targetDate {
                    let formatter = DateFormatter()
                    let _ = formatter.dateStyle = .medium
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(formatter.string(from: targetDate))
                    }
                    .font(.caption)
                    .foregroundStyle(statusColor)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statusColor: Color {
        if goal.isAchieved { return .green }
        guard let isOnTrack = goal.isOnTrack else { return .white.opacity(0.5) }
        return isOnTrack ? .green : .orange
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: AppSection.finance.gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        GoalsListView()
    }
}
