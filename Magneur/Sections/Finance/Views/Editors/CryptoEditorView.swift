//
//  CryptoEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Editor for cryptocurrency holdings
struct CryptoEditorView: View {
    @State private var item: FinancialItem
    @State private var quantityText: String
    let onSave: () -> Void

    // Common crypto coins for quick selection
    let popularCoins = [
        ("bitcoin", "Bitcoin (BTC)"),
        ("ethereum", "Ethereum (ETH)"),
        ("tether", "Tether (USDT)"),
        ("binancecoin", "BNB"),
        ("solana", "Solana (SOL)"),
        ("ripple", "XRP"),
        ("cardano", "Cardano (ADA)"),
        ("dogecoin", "Dogecoin (DOGE)")
    ]

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        _quantityText = State(initialValue: item.quantity > 0 ? "\(item.quantity)" : "")
        self.onSave = onSave
    }

    var body: some View {
        ItemEditorWrapper(
            title: item.id == nil ? "Add Cryptocurrency" : "Edit Cryptocurrency",
            canSave: canSave,
            onSave: saveItem
        ) {
            EditorComponents.InputSection(title: "Cryptocurrency") {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Coin ID (e.g., bitcoin)", text: Binding(
                        get: { item.coinId ?? "" },
                        set: { item.coinId = $0.lowercased() }
                    ))
                    .foregroundStyle(.white)

                    Text("Popular coins:")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(popularCoins, id: \.0) { coin in
                            Button {
                                item.coinId = coin.0
                                item.name = coin.1
                            } label: {
                                Text(coin.1)
                                    .font(.caption)
                                    .foregroundStyle(item.coinId == coin.0 ? .white : .white.opacity(0.7))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(item.coinId == coin.0 ? .white.opacity(0.3) : .white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                }
            }

            EditorComponents.InputSection(title: "Display Name") {
                TextField("e.g., Bitcoin (BTC)", text: $item.name)
                    .foregroundStyle(.white)
            }

            EditorComponents.InputSection(title: "Quantity") {
                EditorComponents.QuantityField(text: $quantityText, label: "coins")
            }

            EditorComponents.InputSection(title: "Currency") {
                EditorComponents.CurrencyPicker(currency: $item.currency)
            }

            Text("Crypto prices will be fetched automatically from CoinGecko.")
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
        !(item.coinId ?? "").isEmpty && !quantityText.isEmpty && (Decimal(string: quantityText) ?? 0) > 0
    }

    private func saveItem() {
        item.quantity = Decimal(string: quantityText) ?? 0
        item.updatedAt = Date()
        FinanceStore.shared.saveItem(item)
        onSave()
    }
}

#Preview {
    CryptoEditorView(item: .crypto()) { }
}
