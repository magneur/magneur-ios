//
//  TravelView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI
import SwiftData

/// Main travel section with tab-based navigation
struct TravelView: View {
    @State private var selectedTab: TravelTab = .journal
    @State private var showingCreateEntry = false

    enum TravelTab: String, CaseIterable {
        case journal = "Journal"
        case map = "Map"
        case trips = "Trips"
        case stats = "Stats"

        var icon: String {
            switch self {
            case .journal: return "book.fill"
            case .map: return "map.fill"
            case .trips: return "suitcase.fill"
            case .stats: return "chart.bar.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: AppSection.travel.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom tab bar
                    HStack(spacing: 0) {
                        ForEach(TravelTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 20))
                                    Text(tab.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .background(.ultraThinMaterial.opacity(0.3))

                    // Tab content
                    TabView(selection: $selectedTab) {
                        JournalListView(showingCreateEntry: $showingCreateEntry)
                            .tag(TravelTab.journal)

                        TravelMapView()
                            .tag(TravelTab.map)

                        TripListPlaceholderView()
                            .tag(TravelTab.trips)

                        TravelStatsPlaceholderView()
                            .tag(TravelTab.stats)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Travel")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if selectedTab == .journal {
                        Button {
                            showingCreateEntry = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingCreateEntry) {
            JournalEntryEditorView()
        }
    }
}

// MARK: - Placeholder Views

/// Placeholder for map view
struct TravelMapPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))
            Text("World Map")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            Text("View your visited countries and regions")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Placeholder for trips list
struct TripListPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "suitcase.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))
            Text("Trips")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            Text("Organize your journal entries into trips")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Placeholder for stats view
struct TravelStatsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))
            Text("Travel Stats")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            Text("See your travel statistics and collected flags")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TravelView()
        .modelContainer(for: [StoredJournalEntry.self, StoredTrip.self], inMemory: true)
}
