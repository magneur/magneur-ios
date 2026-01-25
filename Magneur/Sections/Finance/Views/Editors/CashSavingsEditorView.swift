//
//  CashSavingsEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for cash and savings accounts
struct CashSavingsEditorView: View {
    @State private var item: FinancialItem
    @State private var balanceText: String
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _balanceText = State(initialValue: item.manualValue > 0 ? "\(item.manualValue)" : "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add Cash & Savings" : "Edit Cash & Savings",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Account Name") {
                TextField("e.g., Chase Savings", text: $item.name)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Current Balance") {
                EditorComponents.CurrencyField(
                    currencySymbol: currencySymbol,
                    text: $balanceText
                )
            }

            EditorComponents.InputSection(title: "Institution (Optional)") {
                TextField("e.g., Chase Bank", text: Binding(
                    get: { item.institution ?? "" },
                    set: { item.institution = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Currency") {
                EditorComponents.CurrencyPicker(currency: $item.currency)
            }

            EditorComponents.InputSection(title: "Notes (Optional)") {
                TextField("Add notes...", text: $item.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.plain)
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
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    CashSavingsEditorView(item: .cashSavings()) { }
}
