//
//  FinanceView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI
import SwiftData

/// Main finance section with tab-based navigation
struct FinanceView: View {
    @State private var selectedTab: FinanceTab = .dashboard
    @State private var showingCreateItem = false

    enum FinanceTab: String, CaseIterable {
        case dashboard = "Dashboard"
        case assets = "Assets"
        case liabilities = "Liabilities"
        case goals = "Goals"

        var icon: String {
            switch self {
            case .dashboard: return "chart.pie.fill"
            case .assets: return "arrow.up.circle.fill"
            case .liabilities: return "arrow.down.circle.fill"
            case .goals: return "target"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: AppSection.finance.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom tab bar
                    HStack(spacing: 0) {
                        ForEach(FinanceTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 18))
                                    Text(tab.rawValue)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                    .background(.ultraThinMaterial.opacity(0.3))

                    // Tab content
                    TabView(selection: $selectedTab) {
                        DashboardView()
                            .tag(FinanceTab.dashboard)

                        AssetsListView(showingCreateItem: $showingCreateItem)
                            .tag(FinanceTab.assets)

                        LiabilitiesListView(showingCreateItem: $showingCreateItem)
                            .tag(FinanceTab.liabilities)

                        GoalsListView()
                            .tag(FinanceTab.goals)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Finance")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingCreateItem) {
            ItemCreationMenuView()
        }
    }
}

#Preview {
    FinanceView()
        .modelContainer(for: [
            StoredFinancialItem.self,
            StoredFinancialGoal.self,
            StoredNetWorthSnapshot.self,
            StoredFinanceSettings.self
        ], inMemory: true)
}
