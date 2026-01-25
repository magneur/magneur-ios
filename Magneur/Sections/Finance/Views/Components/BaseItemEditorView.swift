//
//  BaseItemEditorView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Reusable components for item editors
struct EditorComponents {
    /// Standard input section wrapper
    struct InputSection<Content: View>: View {
        let title: String
        @ViewBuilder let content: () -> Content

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                content()
                    .padding()
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
            .background(.ultraThinMaterial.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    /// Currency input field
    struct CurrencyField: View {
        let currencySymbol: String
        @Binding var text: String

        var body: some View {
            HStack {
                Text(currencySymbol)
                    .foregroundStyle(.white.opacity(0.5))
                TextField("0", text: $text)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .foregroundStyle(.white)
            }
        }
    }

    /// Currency picker
    struct CurrencyPicker: View {
        @Binding var currency: String

        var body: some View {
            Picker("Currency", selection: $currency) {
                ForEach(Currency.commonCurrencies) { curr in
                    Text("\(curr.code) - \(curr.name)")
                        .tag(curr.code)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
        }
    }

    /// Quantity input field
    struct QuantityField: View {
        @Binding var text: String
        let label: String

        var body: some View {
            HStack {
                TextField("0", text: $text)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .foregroundStyle(.white)
                Text(label)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    /// Interest rate input field
    struct InterestRateField: View {
        @Binding var text: String

        var body: some View {
            HStack {
                TextField("0.00", text: $text)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .foregroundStyle(.white)
                Text("%")
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

/// Base structure for item editor views
struct ItemEditorWrapper<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let canSave: Bool
    let onSave: () -> Void
    @ViewBuilder let content: () -> Content

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
                        content()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}
