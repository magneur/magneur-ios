//
//  DashboardView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI
import Charts

/// Main dashboard showing net worth overview and quick stats
struct DashboardView: View {
    @State private var netWorth: (assets: Decimal, liabilities: Decimal, netWorth: Decimal) = (0, 0, 0)
    @State private var snapshots: [NetWorthSnapshot] = []
    @State private var selectedRange: ChartRange = .threeMonths

    enum ChartRange: String, CaseIterable {
        case oneMonth = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case oneYear = "1Y"
        case all = "All"

        var months: Int? {
            switch self {
            case .oneMonth: return 1
            case .threeMonths: return 3
            case .sixMonths: return 6
            case .oneYear: return 12
            case .all: return nil
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Net Worth Card
                netWorthCard

                // Quick Stats
                quickStatsSection

                // Chart
                chartSection

                // Recent Activity placeholder
                recentActivitySection
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
    }

    // MARK: - Net Worth Card

    private var netWorthCard: some View {
        VStack(spacing: 12) {
            Text("Net Worth")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Text(formatCurrency(netWorth.netWorth))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Assets")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(formatCurrency(netWorth.assets))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 1, height: 30)

                VStack(spacing: 4) {
                    Text("Liabilities")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(formatCurrency(netWorth.liabilities))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            quickStatCard(
                title: "Assets",
                value: "\(FinanceStore.shared.fetchAssets().count)",
                icon: "arrow.up.circle.fill",
                color: .green
            )

            quickStatCard(
                title: "Liabilities",
                value: "\(FinanceStore.shared.fetchLiabilities().count)",
                icon: "arrow.down.circle.fill",
                color: .red
            )

            quickStatCard(
                title: "Goals",
                value: "\(FinanceStore.shared.totalGoalCount())",
                icon: "target",
                color: .blue
            )
        }
    }

    private func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Net Worth History")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                // Range selector
                HStack(spacing: 0) {
                    ForEach(ChartRange.allCases, id: \.self) { range in
                        Button {
                            withAnimation {
                                selectedRange = range
                            }
                        } label: {
                            Text(range.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedRange == range ? .white.opacity(0.2) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .foregroundStyle(.white.opacity(selectedRange == range ? 1 : 0.6))
                    }
                }
            }

            if filteredSnapshots.isEmpty {
                emptyChartPlaceholder
            } else {
                netWorthChart
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var filteredSnapshots: [NetWorthSnapshot] {
        guard let months = selectedRange.months else { return snapshots }
        let cutoffDate = Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()
        return snapshots.filter { $0.date >= cutoffDate }
    }

    private var netWorthChart: some View {
        Chart(filteredSnapshots, id: \.id) { snapshot in
            LineMark(
                x: .value("Date", snapshot.date),
                y: .value("Net Worth", Double(truncating: snapshot.netWorth as NSDecimalNumber))
            )
            .foregroundStyle(.white)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", snapshot.date),
                y: .value("Net Worth", Double(truncating: snapshot.netWorth as NSDecimalNumber))
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.white.opacity(0.3), .white.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.2))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.2))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(formatCompactCurrency(Decimal(amount)))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
        .frame(height: 200)
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.4))

            Text("No history yet")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            Text("Add assets and liabilities to start tracking your net worth")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 8) {
                tipRow(icon: "plus.circle", text: "Add your first asset to start tracking net worth")
                tipRow(icon: "arrow.triangle.2.circlepath", text: "Update values regularly for accurate tracking")
                tipRow(icon: "target", text: "Set financial goals to stay motivated")
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func loadData() {
        netWorth = FinanceStore.shared.calculateNetWorth()
        snapshots = FinanceStore.shared.fetchAllSnapshots()

        // Create daily snapshot if needed
        if !FinanceStore.shared.hasSnapshotForToday() && FinanceStore.shared.totalItemCount() > 0 {
            let settings = FinanceStore.shared.fetchSettings()
            FinanceStore.shared.createSnapshot(currency: settings.baseCurrency)
            snapshots = FinanceStore.shared.fetchAllSnapshots()
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let settings = FinanceStore.shared.fetchSettings()
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = settings.baseCurrency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    private func formatCompactCurrency(_ amount: Decimal) -> String {
        let doubleAmount = Double(truncating: amount as NSDecimalNumber)
        if abs(doubleAmount) >= 1_000_000 {
            return String(format: "%.1fM", doubleAmount / 1_000_000)
        } else if abs(doubleAmount) >= 1_000 {
            return String(format: "%.0fK", doubleAmount / 1_000)
        }
        return String(format: "%.0f", doubleAmount)
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

        DashboardView()
    }
}
