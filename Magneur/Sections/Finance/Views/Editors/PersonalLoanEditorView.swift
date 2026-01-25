//
//  PersonalLoanEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for personal loan liabilities
struct PersonalLoanEditorView: View {
    @State private var item: FinancialItem
    @State private var balanceText: String
    @State private var originalAmountText: String
    @State private var interestRateText: String
    @State private var minimumPaymentText: String
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _balanceText = State(initialValue: item.manualValue > 0 ? "\(item.manualValue)" : "")
        _originalAmountText = State(initialValue: item.originalAmount.map { "\($0)" } ?? "")
        _interestRateText = State(initialValue: item.interestRate.map { "\(NSDecimalNumber(decimal: $0 * 100).doubleValue)" } ?? "")
        _minimumPaymentText = State(initialValue: item.minimumPayment.map { "\($0)" } ?? "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add Personal Loan" : "Edit Personal Loan",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Loan Name") {
                TextField("e.g., SoFi Personal Loan", text: $item.name)
                    .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Current Balance") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $balanceText)
            }

            EditorComponents.InputSection(title: "Original Loan Amount (Optional)") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $originalAmountText)
            }

            EditorComponents.InputSection(title: "Interest Rate (Optional)") {
                EditorComponents.InterestRateField(text: $interestRateText)
            }

            EditorComponents.InputSection(title: "Monthly Payment (Optional)") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $minimumPaymentText)
            }

            EditorComponents.InputSection(title: "Currency") {
                EditorComponents.CurrencyPicker(currency: $item.currency)
            }

            EditorComponents.InputSection(title: "Notes (Optional)") {
                TextField("Add notes...", text: $item.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .foregroundStyle(.white)
            }
        }
    }

    private var currencySymbol: String {
        Currency.currency(forCode: item.currency)?.symbol ?? "$"
    }

    private var canSave: Bool {
        !item.name.isEmpty && !balanceText.isEmpty
    }

    private func saveItem() {
        item.manualValue = Decimal(string: balanceText) ?? 0
        item.originalAmount = Decimal(string: originalAmountText)
        if let rateText = Double(interestRateText) {
            item.interestRate = Decimal(rateText / 100)
        }
        item.minimumPayment = Decimal(string: minimumPaymentText)
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    PersonalLoanEditorView(item: .personalLoan()) { }
}
