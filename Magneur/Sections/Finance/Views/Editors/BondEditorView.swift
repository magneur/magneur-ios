//
//  BondEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for bonds
struct BondEditorView: View {
    @State private var item: FinancialItem
    @State private var valueText: String
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _valueText = State(initialValue: item.manualValue > 0 ? "\(item.manualValue)" : "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add Bond" : "Edit Bond",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Bond Name") {
                TextField("e.g., US Treasury 10Y", text: $item.name)
                    .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Current Value") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $valueText)
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
        !item.name.isEmpty && !valueText.isEmpty
    }

    private func saveItem() {
        item.manualValue = Decimal(string: valueText) ?? 0
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    BondEditorView(item: .bond()) { }
}
