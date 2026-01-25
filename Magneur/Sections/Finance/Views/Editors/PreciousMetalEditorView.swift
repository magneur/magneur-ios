//
//  PreciousMetalEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for precious metals (gold, silver, platinum, palladium)
struct PreciousMetalEditorView: View {
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
            title: item.id == nil ? "Add Precious Metal" : "Edit Precious Metal",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Metal Type") {
                Picker("Metal", selection: Binding(
                    get: { item.metalType ?? .gold },
                    set: {
                        item.metalType = $0
                        item.name = $0.displayName
                    }
                )) {
                    ForEach(MetalType.allCases) { metal in
                        HStack {
                            Text(metal.displayName)
                            if !metal.hasFreePricing {
                                Text("(manual)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(metal)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
            }

            EditorComponents.InputSection(title: "Quantity (Troy Ounces)") {
                EditorComponents.QuantityField(text: $quantityText, label: "oz")
            }

            EditorComponents.InputSection(title: "Currency") {
                EditorComponents.CurrencyPicker(currency: $item.currency)
            }

            if item.metalType?.hasFreePricing == false {
                Text("Note: Live prices are not available for \(item.metalType?.displayName ?? "this metal"). You'll need to update values manually.")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding()
            }

            EditorComponents.InputSection(title: "Notes (Optional)") {
                TextField("Add notes...", text: $item.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .foregroundStyle(.white)
            }
        }
    }

    private var canSave: Bool {
        item.metalType != nil && !quantityText.isEmpty && (Decimal(string: quantityText) ?? 0) > 0
    }

    private func saveItem() {
        item.quantity = Decimal(string: quantityText) ?? 0
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    PreciousMetalEditorView(item: .preciousMetal(metalType: .gold)) { }
}
