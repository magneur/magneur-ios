//
//  LiabilityDetailView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Detail view for viewing and editing a liability
struct LiabilityDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var item: FinancialItem
    @State private var showingDeleteConfirmation = false
    @State private var isEditing = false
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
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
                        // Balance card
                        balanceCard

                        // Payoff progress
                        if item.payoffProgress != nil {
                            payoffProgressCard
                        }

                        // Details card
                        detailsCard

                        // Notes
                        if !item.notes.isEmpty {
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
                    Text(item.displayName)
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
            editSheet
        }
        .confirmationDialog("Delete Liability", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                FinanceStore.shared.deleteItem(item)
                onSave()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this liability? This action cannot be undone.")
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Current Balance")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Text(item.formattedValue())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if let payment = item.minimumPayment {
                Text("\(formatCurrency(payment)) /month minimum")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.red.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var payoffProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Payoff Progress")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("\(Int((item.payoffProgress ?? 0) * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.green)
                        .frame(width: geometry.size.width * CGFloat(item.payoffProgress ?? 0))
                }
            }
            .frame(height: 10)

            if let original = item.originalAmount {
                let paid = original - item.manualValue
                HStack {
                    Text("\(formatCurrency(paid)) paid")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()

                    Text("of \(formatCurrency(original))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "Type", value: item.itemType.displayName)

            if let rate = item.interestRate {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Interest Rate", value: String(format: "%.2f%%", NSDecimalNumber(decimal: rate * 100).doubleValue))
            }

            if let dueDay = item.dueDay {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Due Day", value: "Day \(dueDay)")
            }

            if let address = item.address, !address.isEmpty {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Property", value: address)
            }

            Divider().background(.white.opacity(0.2))
            detailRow(label: "Currency", value: item.currency)

            Divider().background(.white.opacity(0.2))
            detailRow(label: "Added", value: item.formattedDate)
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

            Text(item.notes)
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
            Label("Delete Liability", systemImage: "trash")
                .font(.headline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private var editSheet: some View {
        switch item.itemType {
        case .mortgage:
            MortgageEditorView(item: item) { isEditing = false; loadItem() }
        case .autoLoan:
            AutoLoanEditorView(item: item) { isEditing = false; loadItem() }
        case .studentLoan:
            StudentLoanEditorView(item: item) { isEditing = false; loadItem() }
        case .creditCard:
            CreditCardEditorView(item: item) { isEditing = false; loadItem() }
        case .personalLoan:
            PersonalLoanEditorView(item: item) { isEditing = false; loadItem() }
        case .businessLoan:
            BusinessLoanEditorView(item: item) { isEditing = false; loadItem() }
        case .medicalDebt:
            MedicalDebtEditorView(item: item) { isEditing = false; loadItem() }
        case .otherLiability:
            OtherLiabilityEditorView(item: item) { isEditing = false; loadItem() }
        default:
            EmptyView()
        }
    }

    private func loadItem() {
        if let id = item.id, let updated = FinanceStore.shared.fetchItem(byId: id) {
            item = updated
            onSave()
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = item.currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

#Preview {
    LiabilityDetailView(item: .creditCard(name: "Chase Sapphire", balance: 2500)) { }
}
