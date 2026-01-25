//
//  RetirementAccountEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for retirement accounts
struct RetirementAccountEditorView: View {
    @State private var item: FinancialItem
    @State private var balanceText: String
    let onSave: () -> Void

    let accountTypes = ["401(k)", "Traditional IRA", "Roth IRA", "SEP IRA", "403(b)", "457(b)", "Pension", "Other"]

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _balanceText = State(initialValue: item.manualValue > 0 ? "\(item.manualValue)" : "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add Retirement Account" : "Edit Retirement Account",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Account Name") {
                TextField("e.g., Fidelity 401(k)", text: $item.name)
                    .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Account Type") {
                Picker("Type", selection: Binding(
                    get: { item.accountType ?? "401(k)" },
                    set: { item.accountType = $0 }
                )) {
                    ForEach(accountTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
            }

            EditorComponents.InputSection(title: "Current Balance") {
                EditorComponents.CurrencyField(currencySymbol: currencySymbol, text: $balanceText)
            }

            EditorComponents.InputSection(title: "Institution (Optional)") {
                TextField("e.g., Fidelity, Vanguard", text: Binding(
                    get: { item.institution ?? "" },
                    set: { item.institution = $0.isEmpty ? nil : $0 }
                ))
                .foregroundStyle(.white)
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
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    RetirementAccountEditorView(item: .retirementAccount()) { }
}
