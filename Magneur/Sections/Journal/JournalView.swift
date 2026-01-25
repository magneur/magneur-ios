//
//  JournalView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI
import SwiftData

/// Main journal section with tab-based navigation
struct JournalView: View {
    @State private var selectedTab: JournalTab = .entries
    @State private var showingCreateEntry = false

    enum JournalTab: String, CaseIterable {
        case entries = "Entries"
        case calendar = "Calendar"
        case stats = "Stats"

        var icon: String {
            switch self {
            case .entries: return "book.fill"
            case .calendar: return "calendar"
            case .stats: return "chart.bar.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: AppSection.journal.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom tab bar
                    HStack(spacing: 0) {
                        ForEach(JournalTab.allCases, id: \.self) { tab in
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
                        MindsetEntriesListView(showingCreateEntry: $showingCreateEntry)
                            .tag(JournalTab.entries)

                        JournalCalendarView()
                            .tag(JournalTab.calendar)

                        JournalStatsView()
                            .tag(JournalTab.stats)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Journal")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingCreateEntry) {
            EntryCreationMenuView()
        }
    }
}

#Preview {
    JournalView()
        .modelContainer(for: [StoredMindsetEntry.self], inMemory: true)
}
