//
//  MindsetEntriesListView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// List view displaying all journal entries with filtering
struct MindsetEntriesListView: View {
    @Binding var showingCreateEntry: Bool
    @State private var selectedType: JournalEntryType?
    @State private var entries: [MindsetEntry] = []
    @State private var selectedEntry: MindsetEntry?
    @State private var searchText: String = ""

    var filteredEntries: [MindsetEntry] {
        var result = entries

        // Filter by type
        if let type = selectedType {
            result = result.filter { $0.entryType == type }
        }

        // Filter by search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { entry in
                entry.title.lowercased().contains(query) ||
                entry.content.lowercased().contains(query) ||
                entry.previewText.lowercased().contains(query)
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips
            EntryTypeFilterView(selectedType: $selectedType)
                .padding(.vertical, 12)

            // Entry list
            if filteredEntries.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            MindsetEntryCardView(entry: entry) {
                                selectedEntry = entry
                            } onDelete: {
                                deleteEntry(entry)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search entries...")
        .sheet(item: $selectedEntry) { entry in
            entryEditor(for: entry)
        }
        .onAppear {
            loadEntries()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: selectedType?.icon ?? "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))

            if let type = selectedType {
                Text("No \(type.displayName) entries yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            } else {
                Text("No journal entries yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }

            Text("Tap + to create your first entry")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Button {
                showingCreateEntry = true
            } label: {
                Label("Create Entry", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func entryEditor(for entry: MindsetEntry) -> some View {
        switch entry.entryType {
        case .regularJournal:
            RegularJournalEditorView(entry: entry) {
                loadEntries()
            }
        case .dailyBullet:
            DailyBulletEditorView(entry: entry) {
                loadEntries()
            }
        case .bigGoal:
            BigGoalEditorView(entry: entry) {
                loadEntries()
            }
        case .imaginalAct:
            ImaginalActEditorView(entry: entry) {
                loadEntries()
            }
        case .rewriteAssumption:
            RewriteAssumptionEditorView(entry: entry) {
                loadEntries()
            }
        }
    }

    private func loadEntries() {
        entries = JournalStore.shared.fetchAllEntries()
    }

    private func deleteEntry(_ entry: MindsetEntry) {
        JournalStore.shared.deleteEntry(entry)
        loadEntries()
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        MindsetEntriesListView(showingCreateEntry: .constant(false))
    }
}
