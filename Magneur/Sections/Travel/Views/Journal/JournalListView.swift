//
//  JournalListView.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import SwiftUI

/// List view showing all journal entries
struct JournalListView: View {
    @Binding var showingCreateEntry: Bool
    @State private var entries: [JournalEntry] = []
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if entries.isEmpty {
                    emptyStateView
                } else {
                    ForEach(entries) { entry in
                        JournalEntryCardView(entry: entry)
                            .onTapGesture {
                                selectedEntry = entry
                            }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadEntries()
        }
        .sheet(item: $selectedEntry) { entry in
            JournalEntryDetailView(entry: entry)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))

            Text("No Journal Entries")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text("Start documenting your travels by\ncreating your first journal entry")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button {
                showingCreateEntry = true
            } label: {
                Label("Create Entry", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func loadEntries() {
        entries = TravelStore.shared.fetchJournalEntries()
    }
}

/// Card view for a single journal entry
struct JournalEntryCardView: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with place and date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.place.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(entry.place.shortLocationDescription)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Entry text preview
            if !entry.text.isEmpty {
                Text(entry.text)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
            }

            // Photo count indicator
            if entry.hasPhotos {
                HStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.caption)
                    Text("\(entry.photos.count) photo\(entry.photos.count == 1 ? "" : "s")")
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Detail view for a journal entry
struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Place header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if let category = entry.place.category {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.place.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Text(entry.place.fullLocationDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(entry.createdAt.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal)

                    Divider()

                    // Journal text
                    if !entry.text.isEmpty {
                        Text(entry.text)
                            .font(.body)
                            .padding(.horizontal)
                    }

                    // Photos placeholder
                    if entry.hasPhotos {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Photos")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(entry.sortedPhotos) { photo in
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 120, height: 120)
                                            .overlay {
                                                Image(systemName: "photo")
                                                    .font(.title)
                                                    .foregroundStyle(.secondary)
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.cyan, .teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        JournalListView(showingCreateEntry: .constant(false))
    }
}
