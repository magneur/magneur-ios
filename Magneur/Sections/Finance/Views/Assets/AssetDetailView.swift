//
//  AssetDetailView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Detail view for viewing and editing an asset
struct AssetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var item: FinancialItem
    @State private var showingDeleteConfirmation = false
    @State private var isEditing = false
    let onSave: () -> Void

    init(item: FinancialItem, onSave: @escaping () -> Void) {
        _item = State(initialValue: item)
        self.onSave = onSave
    }

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
                        // Value card
                        valueCard

                        // Details card
                        detailsCard

                        // Notes
                        if !item.notes.isEmpty {
                            notesCard
                        }

                        // Delete button
                        deleteButton
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(item.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $isEditing) {
            editSheet
        }
        .confirmationDialog("Delete Asset", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                FinanceStore.shared.deleteItem(item)
                onSave()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this asset? This action cannot be undone.")
        }
    }

    private var valueCard: some View {
        VStack(spacing: 8) {
            Text("Current Value")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Text(item.formattedValue())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if item.itemType.supportsLivePrice {
                HStack(spacing: 4) {
                    Text("\(item.quantity) units")

                    if let lastUpdate = item.formattedLastUpdate {
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        Text("Updated \(lastUpdate)")
                            .foregroundStyle(item.isPriceStale ? .orange : .white.opacity(0.6))
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "Type", value: item.itemType.displayName)

            if let ticker = item.ticker, !ticker.isEmpty {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Ticker", value: ticker)
            }

            if let coinId = item.coinId, !coinId.isEmpty {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Coin", value: coinId)
            }

            if let metal = item.metalType {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Metal", value: metal.displayName)
            }

            if item.quantity > 0 {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Quantity", value: "\(item.quantity)")
            }

            if let address = item.address, !address.isEmpty {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Address", value: address)
            }

            if let institution = item.institution, !institution.isEmpty {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Institution", value: institution)
            }

            if let accountType = item.accountType, !accountType.isEmpty {
                Divider().background(.white.opacity(0.2))
                detailRow(label: "Account Type", value: accountType)
            }

            Divider().background(.white.opacity(0.2))
            detailRow(label: "Currency", value: item.currency)

            Divider().background(.white.opacity(0.2))
            detailRow(label: "Added", value: item.formattedDate)
        }
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Text(item.notes)
                .font(.body)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            Label("Delete Asset", systemImage: "trash")
                .font(.headline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private var editSheet: some View {
        switch item.itemType {
        case .cashSavings:
            CashSavingsEditorView(item: item) { isEditing = false; loadItem() }
        case .realEstate:
            RealEstateEditorView(item: item) { isEditing = false; loadItem() }
        case .vehicle:
            VehicleEditorView(item: item) { isEditing = false; loadItem() }
        case .preciousMetal:
            PreciousMetalEditorView(item: item) { isEditing = false; loadItem() }
        case .stock:
            StockEditorView(item: item) { isEditing = false; loadItem() }
        case .etfMutualFund:
            ETFEditorView(item: item) { isEditing = false; loadItem() }
        case .bond:
            BondEditorView(item: item) { isEditing = false; loadItem() }
        case .crypto:
            CryptoEditorView(item: item) { isEditing = false; loadItem() }
        case .businessEquity:
            BusinessEquityEditorView(item: item) { isEditing = false; loadItem() }
        case .retirementAccount:
            RetirementAccountEditorView(item: item) { isEditing = false; loadItem() }
        case .otherAsset:
            OtherAssetEditorView(item: item) { isEditing = false; loadItem() }
        default:
            EmptyView()
        }
    }

    private func loadItem() {
        if let id = item.id, let updated = FinanceStore.shared.fetchItem(byId: id) {
            item = updated
            onSave()
        }
    }
}

#Preview {
    AssetDetailView(item: .cashSavings(name: "Savings Account", balance: 10000)) { }
}
