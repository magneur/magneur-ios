//
//  LiabilitiesListView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// List view showing all liabilities grouped by type
struct LiabilitiesListView: View {
    @Binding var showingCreateItem: Bool
    @State private var liabilities: [FinancialItem] = []
    @State private var selectedItem: FinancialItem?

    var body: some View {
        ScrollView {
            if liabilities.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    // Total debt card
                    totalDebtCard

                    ForEach(groupedLiabilities, id: \.0) { type, items in
                        liabilitySection(type: type, items: items)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadLiabilities()
        }
        .sheet(item: $selectedItem) { item in
            LiabilityDetailView(item: item) {
                loadLiabilities()
            }
        }
    }

    private var totalDebtCard: some View {
        let totalDebt = liabilities.reduce(Decimal(0)) { $0 + $1.currentValue }
        let settings = FinanceStore.shared.fetchSettings()
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = settings.baseCurrency

        return VStack(spacing: 8) {
            Text("Total Debt")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Text(formatter.string(from: totalDebt as NSDecimalNumber) ?? "\(totalDebt)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("\(liabilities.count) accounts")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.red.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var groupedLiabilities: [(FinancialItemType, [FinancialItem])] {
        let grouped = Dictionary(grouping: liabilities) { $0.itemType }
        return FinancialItemType.liabilityTypes
            .compactMap { type in
                guard let items = grouped[type], !items.isEmpty else { return nil }
                return (type, items)
            }
    }

    private func liabilitySection(type: FinancialItemType, items: [FinancialItem]) -> some View {
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
                    LiabilityCardView(item: item)
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

            Image(systemName: "arrow.down.circle")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.4))

            Text("No Liabilities")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text("Great! You don't have any debts tracked.\nAdd liabilities to monitor your payoff progress.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                showingCreateItem = true
            } label: {
                Label("Add Liability", systemImage: "plus")
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

    private func loadLiabilities() {
        liabilities = FinanceStore.shared.fetchLiabilities()
    }

    private func formatTotal(_ items: [FinancialItem]) -> String {
        let total = items.reduce(Decimal(0)) { $0 + $1.currentValue }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = FinanceStore.shared.fetchSettings().baseCurrency
        return formatter.string(from: total as NSDecimalNumber) ?? "\(total)"
    }
}

/// Card view for individual liability
struct LiabilityCardView: View {
    let item: FinancialItem

    var body: some View {
        VStack(spacing: 8) {
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

                    if let rate = item.interestRate {
                        Text("\(NSDecimalNumber(decimal: rate * 100).doubleValue, specifier: "%.2f")% APR")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                Spacer()

                // Value
                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.formattedValue())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    if let payment = item.minimumPayment {
                        Text("\(formatPayment(payment, currency: item.currency)) /mo")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }

            // Progress bar (if original amount available)
            if let progress = item.payoffProgress {
                VStack(spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.2))

                            RoundedRectangle(cornerRadius: 2)
                                .fill(.green)
                                .frame(width: geometry.size.width * CGFloat(progress))
                        }
                    }
                    .frame(height: 4)

                    HStack {
                        Text("\(Int(progress * 100))% paid off")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatPayment(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSDecimalNumber) ?? ""
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

        LiabilitiesListView(showingCreateItem: .constant(false))
    }
}
