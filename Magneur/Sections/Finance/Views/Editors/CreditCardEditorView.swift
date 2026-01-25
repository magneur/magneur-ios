//
//  CreditCardEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for credit card liabilities
struct CreditCardEditorView: View {
    @State private var item: FinancialItem
    @State private var balanceText: String
    @State private var interestRateText: String
    @State private var minimumPaymentText: String
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _balanceText = State(initialValue: item.manualValue > 0 ? "\(item.manualValue)" : "")
        _interestRateText = State(initialValue: item.interestRate.map { "\(NSDecimalNumber(decimal: $0 * 100).doubleValue)" } ?? "")
        _minimumPaymentText = State(initialValue: item.minimumPayment.map { "\($0)" } ?? "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add Credit Card" : "Edit Credit Card",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Card Name") {
                TextField("e.g., Chase Sapphire Preferred", text: $item.name)
                    .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Current Balance") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $balanceText)
            }

            EditorComponents.InputSection(title: "APR (Optional)") {
                EditorComponents.InterestRateField(text: $interestRateText)
            }

            EditorComponents.InputSection(title: "Minimum Payment (Optional)") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $minimumPaymentText)
            }

            EditorComponents.InputSection(title: "Payment Due Day (Optional)") {
                Picker("Due Day", selection: Binding(
                    get: { item.dueDay ?? 1 },
                    set: { item.dueDay = $0 }
                )) {
                    ForEach(1...28, id: \.self) { day in
                        Text("Day \(day)").tag(day)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
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
    CreditCardEditorView(item: .creditCard()) { }
}
