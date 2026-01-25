//
//  RealEstateEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for real estate properties
struct RealEstateEditorView: View {
    @State private var item: FinancialItem
    @State private var valueText: String
    @State private var purchasePriceText: String
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _valueText = State(initialValue: item.manualValue > 0 ? "\(item.manualValue)" : "")
        _purchasePriceText = State(initialValue: item.purchasePrice.map { "\($0)" } ?? "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add Real Estate" : "Edit Real Estate",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Property Name") {
                TextField("e.g., Primary Residence", text: $item.name)
                    .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Address (Optional)") {
                TextField("e.g., 123 Main St", text: Binding(
                    get: { item.address ?? "" },
                    set: { item.address = $0.isEmpty ? nil : $0 }
                ))
                .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Current Value") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $valueText)
            }

            EditorComponents.InputSection(title: "Purchase Price (Optional)") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $purchasePriceText)
            }

            EditorComponents.InputSection(title: "Purchase Date (Optional)") {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { item.purchaseDate ?? Date() },
                        set: { item.purchaseDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
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
        !item.name.isEmpty && !valueText.isEmpty
    }

    private func saveItem() {
        item.manualValue = Decimal(string: valueText) ?? 0
        item.purchasePrice = Decimal(string: purchasePriceText)
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    RealEstateEditorView(item: .realEstate()) { }
}
