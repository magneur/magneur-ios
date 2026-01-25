//
//  JournalStore.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation
import SwiftData
import Observation

/// Manages mindset journal entry persistence using SwiftData with CloudKit sync
@Observable
final class JournalStore {

    static let shared = JournalStore()

    private var modelContext: ModelContext?

    private init() {}

    /// Configure with the app's model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Fetch Operations

    /// Fetch all entries sorted by creation date (newest first)
    func fetchAllEntries() -> [MindsetEntry] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredMindsetEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toMindsetEntry() }
        } catch {
            print("Failed to fetch journal entries: \(error)")
            return []
        }
    }

    /// Fetch entries of a specific type
    func fetchEntries(ofType type: JournalEntryType) -> [MindsetEntry] {
        guard let context = modelContext else { return [] }

        let typeRaw = type.rawValue
        let descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.entryTypeRaw == typeRaw },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toMindsetEntry() }
        } catch {
            print("Failed to fetch entries of type \(type): \(error)")
            return []
        }
    }

    /// Fetch entries for a specific date
    func fetchEntries(for date: Date) -> [MindsetEntry] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.createdAt >= startOfDay && $0.createdAt < endOfDay },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toMindsetEntry() }
        } catch {
            print("Failed to fetch entries for date: \(error)")
            return []
        }
    }

    /// Fetch a single entry by ID
    func fetchEntry(byId id: String) -> MindsetEntry? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let stored = try context.fetch(descriptor).first {
                return stored.toMindsetEntry()
            }
        } catch {
            print("Failed to fetch entry by ID: \(error)")
        }
        return nil
    }

    /// Search entries by text content
    func searchEntries(query: String) -> [MindsetEntry] {
        guard let context = modelContext, !query.isEmpty else { return [] }

        let lowercasedQuery = query.lowercased()

        // Fetch all entries and filter in memory (SwiftData has limited string search)
        let descriptor = FetchDescriptor<StoredMindsetEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored
                .filter { entry in
                    entry.title.lowercased().contains(lowercasedQuery) ||
                    entry.content.lowercased().contains(lowercasedQuery) ||
                    (entry.sceneDescription?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (entry.bulletPointsJSON?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (entry.oldAssumptionsJSON?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (entry.newAssumptionsJSON?.lowercased().contains(lowercasedQuery) ?? false)
                }
                .map { $0.toMindsetEntry() }
        } catch {
            print("Failed to search entries: \(error)")
            return []
        }
    }

    // MARK: - Save Operations

    /// Save a new or update existing entry
    func saveEntry(_ entry: MindsetEntry) {
        guard let context = modelContext else { return }

        let id = entry.id ?? UUID().uuidString

        // Check if exists
        var descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.entryTypeRaw = entry.entryType.rawValue
                existing.title = entry.title
                existing.content = entry.content
                existing.tagsJSON = entry.tagsJSON()
                existing.bulletPointsJSON = entry.bulletPointsJSON()
                existing.oldAssumptionsJSON = entry.oldAssumptionsJSON()
                existing.newAssumptionsJSON = entry.newAssumptionsJSON()
                existing.sceneDescription = entry.sceneDescription
                existing.reminderTime = entry.reminderTime
                existing.notificationsEnabled = entry.notificationsEnabled
                existing.updatedAt = Date()
            } else {
                // Create new
                var mutableEntry = entry
                mutableEntry.id = id
                context.insert(mutableEntry.toStoredMindsetEntry())
            }

            try context.save()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }

    // MARK: - Delete Operations

    /// Delete an entry
    func deleteEntry(_ entry: MindsetEntry) {
        guard let context = modelContext, let id = entry.id else { return }

        var descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }

    /// Delete entry by ID
    func deleteEntry(byId id: String) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete entry by ID: \(error)")
        }
    }

    // MARK: - Statistics

    /// Get count of entries by type
    func entryCount(forType type: JournalEntryType) -> Int {
        guard let context = modelContext else { return 0 }

        let typeRaw = type.rawValue
        let descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.entryTypeRaw == typeRaw }
        )

        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("Failed to count entries: \(error)")
            return 0
        }
    }

    /// Get total entry count
    func totalEntryCount() -> Int {
        guard let context = modelContext else { return 0 }

        let descriptor = FetchDescriptor<StoredMindsetEntry>()

        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("Failed to count total entries: \(error)")
            return 0
        }
    }

    /// Get dates that have entries
    func datesWithEntries() -> Set<Date> {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredMindsetEntry>()

        do {
            let stored = try context.fetch(descriptor)
            let calendar = Calendar.current
            return Set(stored.map { calendar.startOfDay(for: $0.createdAt) })
        } catch {
            print("Failed to fetch dates with entries: \(error)")
            return []
        }
    }

    /// Get entry counts grouped by date
    func entryCounts(for month: Date) -> [Date: Int] {
        guard let context = modelContext else { return [:] }

        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return [:]
        }

        let descriptor = FetchDescriptor<StoredMindsetEntry>(
            predicate: #Predicate { $0.createdAt >= startOfMonth && $0.createdAt < endOfMonth }
        )

        do {
            let stored = try context.fetch(descriptor)
            var counts: [Date: Int] = [:]
            for entry in stored {
                let day = calendar.startOfDay(for: entry.createdAt)
                counts[day, default: 0] += 1
            }
            return counts
        } catch {
            print("Failed to fetch entry counts: \(error)")
            return [:]
        }
    }

    /// Calculate current journaling streak
    func currentStreak() -> Int {
        guard let context = modelContext else { return 0 }

        let descriptor = FetchDescriptor<StoredMindsetEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            guard !stored.isEmpty else { return 0 }

            let calendar = Calendar.current
            var streak = 0
            var currentDate = calendar.startOfDay(for: Date())

            // Check if there's an entry today
            let entriesByDay = Dictionary(grouping: stored) { calendar.startOfDay(for: $0.createdAt) }

            while let _ = entriesByDay[currentDate] {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            }

            return streak
        } catch {
            print("Failed to calculate streak: \(error)")
            return 0
        }
    }
}
