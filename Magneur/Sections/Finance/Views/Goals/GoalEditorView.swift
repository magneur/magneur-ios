//
//  GoalEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor view for creating and editing financial goals
struct GoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goal: FinancialGoal
    @State private var targetAmountText: String
    @State private var currentAmountText: String
    @State private var hasTargetDate: Bool
    let onSave: () -> Void

    init(goal: FinancialGoal, onSave: @escaping () -> Void) {
        _goal = State(initialValue: goal)
        _targetAmountText = State(initialValue: goal.targetAmount > 0 ? "\(goal.targetAmount)" : "")
        _currentAmountText = State(initialValue: goal.currentAmount > 0 ? "\(goal.currentAmount)" : "")
        _hasTargetDate = State(initialValue: goal.targetDate != nil)
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
                        // Goal type picker
                        goalTypePicker

                        // Name
                        inputSection(title: "Goal Name") {
                            TextField("e.g., Emergency Fund", text: $goal.name)
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                        }

                        // Target amount
                        inputSection(title: "Target Amount") {
                            HStack {
                                Text(currencySymbol)
                                    .foregroundStyle(.white.opacity(0.5))
                                TextField("0", text: $targetAmountText)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(.white)
                            }
                        }

                        // Current amount
                        inputSection(title: "Current Progress") {
                            HStack {
                                Text(currencySymbol)
                                    .foregroundStyle(.white.opacity(0.5))
                                TextField("0", text: $currentAmountText)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(.white)
                            }
                        }

                        // Currency picker
                        inputSection(title: "Currency") {
                            Picker("Currency", selection: $goal.currency) {
                                ForEach(Currency.commonCurrencies) { currency in
                                    Text("\(currency.code) - \(currency.name)")
                                        .tag(currency.code)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                        }

                        // Target date toggle
                        Toggle(isOn: $hasTargetDate) {
                            Text("Set Target Date")
                                .foregroundStyle(.white)
                        }
                        .tint(.green)
                        .padding()
                        .background(.ultraThinMaterial.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Target date picker
                        if hasTargetDate {
                            inputSection(title: "Target Date") {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { goal.targetDate ?? Date() },
                                        set: { goal.targetDate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(.white)
                            }
                        }

                        // Notes
                        inputSection(title: "Notes (Optional)") {
                            TextField("Add notes...", text: $goal.notes, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(goal.id == nil ? "New Goal" : "Edit Goal")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var goalTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Goal Type")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 12) {
                ForEach(GoalType.allCases) { type in
                    Button {
                        goal.goalType = type
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.title3)
                                .foregroundStyle(goal.goalType == type ? type.accentColor : .white.opacity(0.5))

                            Text(type.displayName)
                                .font(.caption2)
                                .foregroundStyle(goal.goalType == type ? .white : .white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(goal.goalType == type ? .white.opacity(0.2) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func inputSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            content()
                .padding()
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var currencySymbol: String {
        Currency.currency(forCode: goal.currency)?.symbol ?? "$"
    }

    private var canSave: Bool {
        !targetAmountText.isEmpty && (Decimal(string: targetAmountText) ?? 0) > 0
    }

    private func saveGoal() {
        goal.targetAmount = Decimal(string: targetAmountText) ?? 0
        goal.currentAmount = Decimal(string: currentAmountText) ?? 0
        if !hasTargetDate {
            goal.targetDate = nil
        }
        goal.updatedAt = Date()

        FinanceStore.shared.saveGoal(goal)
        onSave()
        dismiss()
    }
}

#Preview {
    GoalEditorView(goal: .savingsTarget()) { }
}
