//
//  ETFEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for ETFs and mutual funds
struct ETFEditorView: View {
    @State private var item: FinancialItem
    @State private var quantityText: String
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _quantityText = State(initialValue: item.quantity > 0 ? "\(item.quantity)" : "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add ETF / Mutual Fund" : "Edit ETF / Mutual Fund",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Ticker Symbol") {
                TextField("e.g., VOO, SPY", text: Binding(
                    get: { item.ticker ?? "" },
                    set: {
                        item.ticker = $0.uppercased()
                        item.name = $0.uppercased()
                    }
                ))
                .textInputAutocapitalization(.characters)
                .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Number of Shares") {
                EditorComponents.QuantityField(text: $quantityText, label: "shares")
            }

            EditorComponents.InputSection(title: "Currency") {
                EditorComponents.CurrencyPicker(currency: $item.currency)
            }

            Text("Fund prices will be fetched automatically from Yahoo Finance.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .padding()

            EditorComponents.InputSection(title: "Notes (Optional)") {
                TextField("Add notes...", text: $item.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .foregroundStyle(.white)
            }
        }
    }

    private var canSave: Bool {
        !(item.ticker ?? "").isEmpty && !quantityText.isEmpty && (Decimal(string: quantityText) ?? 0) > 0
    }

    private func saveItem() {
        item.quantity = Decimal(string: quantityText) ?? 0
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    ETFEditorView(item: .etfMutualFund()) { }
}
