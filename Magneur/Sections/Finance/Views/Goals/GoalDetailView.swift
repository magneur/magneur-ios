//
//  GoalDetailView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Detail view for viewing and editing a financial goal
struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goal: FinancialGoal
    @State private var showingDeleteConfirmation = false
    @State private var isEditing = false
    let onSave: () -> Void

    init(goal: FinancialGoal, onSave: @escaping () -> Void) {
        _goal = State(initialValue: goal)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: AppSection.finance.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Progress card
                        progressCard

                        // Details card
                        detailsCard

                        // Notes
                        if !goal.notes.isEmpty {
                            notesCard
                        }

                        // Delete button
                        deleteButton
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(goal.name.isEmpty ? goal.goalType.displayName : goal.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $isEditing) {
            GoalEditorView(goal: goal) {
                isEditing = false
                loadGoal()
            }
        }
        .confirmationDialog("Delete Goal", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                FinanceStore.shared.deleteGoal(goal)
                onSave()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
    }

    private var progressCard: some View {
        VStack(spacing: 16) {
            // Goal type icon
            Image(systemName: goal.goalType.icon)
                .font(.system(size: 40))
                .foregroundStyle(goal.isAchieved ? .green : goal.goalType.accentColor)

            if goal.isAchieved {
                Text("Goal Achieved!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            } else {
                Text("\(Int(goal.progressPercentage * 100))%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white.opacity(0.2))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(goal.isAchieved ? .green : goal.goalType.accentColor)
                        .frame(width: geometry.size.width * CGFloat(goal.progressPercentage))
                }
            }
            .frame(height: 12)

            // Amounts
            HStack {
                VStack(alignment: .leading) {
                    Text("Current")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(goal.formattedCurrentAmount())
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Target")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(goal.formattedTargetAmount())
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }

            // Remaining
            if !goal.isAchieved {
                Text("\(formatCurrency(goal.remainingAmount)) remaining")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "Type", value: goal.goalType.displayName)

            if let targetDate = goal.targetDate {
                Divider().background(.white.opacity(0.2))
                let formatter = DateFormatter()
                let _ = formatter.dateStyle = .medium
                detailRow(label: "Target Date", value: formatter.string(from: targetDate))

                if let isOnTrack = goal.isOnTrack {
                    Divider().background(.white.opacity(0.2))
                    HStack {
                        Text("Status")
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: isOnTrack ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            Text(isOnTrack ? "On Track" : "Behind Schedule")
                        }
                        .foregroundStyle(isOnTrack ? .green : .orange)
                        .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .padding()
                }
            }

            if let projectedDate = goal.projectedCompletionDate, !goal.isAchieved {
                Divider().background(.white.opacity(0.2))
                let formatter = DateFormatter()
                let _ = formatter.dateStyle = .medium
                detailRow(label: "Projected Completion", value: formatter.string(from: projectedDate))
            }

            Divider().background(.white.opacity(0.2))
            detailRow(label: "Currency", value: goal.currency)

            Divider().background(.white.opacity(0.2))
            let dateFormatter = DateFormatter()
            let _ = dateFormatter.dateStyle = .medium
            detailRow(label: "Created", value: dateFormatter.string(from: goal.createdAt))
        }
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Text(goal.notes)
                .font(.body)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            Label("Delete Goal", systemImage: "trash")
                .font(.headline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func loadGoal() {
        if let id = goal.id, let updated = FinanceStore.shared.fetchGoal(byId: id) {
            goal = updated
            onSave()
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = goal.currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

#Preview {
    GoalDetailView(goal: .savingsTarget(name: "Emergency Fund", targetAmount: 10000)) { }
}
