//
//  AssetsListView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// List view showing all assets grouped by type
struct AssetsListView: View {
    @Binding var showingCreateItem: Bool
    @State private var assets: [FinancialItem] = []
    @State private var selectedItem: FinancialItem?

    var body: some View {
        ScrollView {
            if assets.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(groupedAssets, id: \.0) { type, items in
                        assetSection(type: type, items: items)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadAssets()
        }
        .sheet(item: $selectedItem) { item in
            AssetDetailView(item: item) {
                loadAssets()
            }
        }
    }

    private var groupedAssets: [(FinancialItemType, [FinancialItem])] {
        let grouped = Dictionary(grouping: assets) { $0.itemType }
        return FinancialItemType.assetTypes
            .compactMap { type in
                guard let items = grouped[type], !items.isEmpty else { return nil }
                return (type, items)
            }
    }

    private func assetSection(type: FinancialItemType, items: [FinancialItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            HStack {
                Image(systemName: type.icon)
                    .foregroundStyle(type.accentColor)
                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text(formatTotal(items))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 4)

            // Items
            VStack(spacing: 8) {
                ForEach(items) { item in
                    AssetCardView(item: item)
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "arrow.up.circle")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.4))

            Text("No Assets Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text("Add your first asset to start tracking\nyour net worth")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                showingCreateItem = true
            } label: {
                Label("Add Asset", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding()
    }

    private func loadAssets() {
        assets = FinanceStore.shared.fetchAssets()
    }

    private func formatTotal(_ items: [FinancialItem]) -> String {
        let total = items.reduce(Decimal(0)) { $0 + $1.currentValue }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = FinanceStore.shared.fetchSettings().baseCurrency
        return formatter.string(from: total as NSDecimalNumber) ?? "\(total)"
    }
}

/// Card view for individual asset
struct AssetCardView: View {
    let item: FinancialItem

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: item.itemType.icon)
                .font(.title3)
                .foregroundStyle(item.itemType.accentColor)
                .frame(width: 36, height: 36)
                .background(item.itemType.accentColor.opacity(0.2))
                .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if item.itemType.supportsLivePrice {
                    HStack(spacing: 4) {
                        Text("\(item.quantity) units")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))

                        if let lastUpdate = item.formattedLastUpdate {
                            Text("•")
                                .foregroundStyle(.white.opacity(0.3))
                            Text(lastUpdate)
                                .font(.caption)
                                .foregroundStyle(item.isPriceStale ? .orange : .white.opacity(0.5))
                        }
                    }
                }
            }

            Spacer()

            // Value
            Text(item.formattedValue())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding(12)
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: AppSection.finance.gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        AssetsListView(showingCreateItem: .constant(false))
    }
}
