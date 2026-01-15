//
//  TravelStore.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import Foundation
import SwiftData
import Observation

/// Manages travel data persistence using SwiftData with CloudKit sync
@Observable
final class TravelStore {

    static let shared = TravelStore()

    private var modelContext: ModelContext?

    private init() {}

    /// Configure with the app's model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Journal Entries

    /// Fetch all journal entries
    func fetchJournalEntries() -> [JournalEntry] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredJournalEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.compactMap { $0.toJournalEntry() }
        } catch {
            print("Failed to fetch journal entries: \(error)")
            return []
        }
    }

    /// Fetch journal entries for a specific trip
    func fetchJournalEntries(forTrip tripId: String) -> [JournalEntry] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredJournalEntry>(
            predicate: #Predicate { $0.tripId == tripId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.compactMap { $0.toJournalEntry() }
        } catch {
            print("Failed to fetch journal entries for trip: \(error)")
            return []
        }
    }

    /// Save a new or update existing journal entry
    func saveJournalEntry(_ entry: JournalEntry) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredJournalEntry>(
            predicate: #Predicate { $0.id == entry.id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.text = entry.text
                existing.photosJSON = entry.getPhotosJSON()
                existing.placeJSON = entry.getPlaceJSON()
                existing.updatedAt = Date()
                existing.tripId = entry.tripId
            } else {
                // Create new
                context.insert(entry.toStoredEntry())
            }

            try context.save()

            // Mark country as visited
            if let countryCode = entry.place.countryCode,
               let countryName = entry.place.countryName {
                markCountryVisited(
                    isoCode: countryCode,
                    name: countryName,
                    region: entry.place.regionName
                )
            }
        } catch {
            print("Failed to save journal entry: \(error)")
        }
    }

    /// Delete a journal entry
    func deleteJournalEntry(_ entry: JournalEntry) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredJournalEntry>(
            predicate: #Predicate { $0.id == entry.id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete journal entry: \(error)")
        }
    }

    // MARK: - Trips

    /// Fetch all trips
    func fetchTrips() -> [Trip] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredTrip>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toTrip() }
        } catch {
            print("Failed to fetch trips: \(error)")
            return []
        }
    }

    /// Save a new or update existing trip
    func saveTrip(_ trip: Trip) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredTrip>(
            predicate: #Predicate { $0.id == trip.id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.name = trip.name
                existing.startDate = trip.startDate
                existing.endDate = trip.endDate
                existing.coverPhotoId = trip.coverPhotoId
                existing.entryIdsJSON = trip.getEntryIdsJSON()
                existing.countriesVisitedJSON = trip.getCountriesVisitedJSON()
                existing.updatedAt = Date()
            } else {
                // Create new
                context.insert(trip.toStoredTrip())
            }

            try context.save()
        } catch {
            print("Failed to save trip: \(error)")
        }
    }

    /// Delete a trip
    func deleteTrip(_ trip: Trip) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredTrip>(
            predicate: #Predicate { $0.id == trip.id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete trip: \(error)")
        }
    }

    /// Add an entry to a trip
    func addEntryToTrip(entryId: String, tripId: String) {
        guard let context = modelContext else { return }

        // Update the entry's tripId
        var entryDescriptor = FetchDescriptor<StoredJournalEntry>(
            predicate: #Predicate { $0.id == entryId }
        )
        entryDescriptor.fetchLimit = 1

        var tripDescriptor = FetchDescriptor<StoredTrip>(
            predicate: #Predicate { $0.id == tripId }
        )
        tripDescriptor.fetchLimit = 1

        do {
            if let entry = try context.fetch(entryDescriptor).first,
               let trip = try context.fetch(tripDescriptor).first {
                // Update entry
                entry.tripId = tripId

                // Update trip's entry list
                var entryIds = Trip.decodeEntryIds(from: trip.entryIdsJSON)
                if !entryIds.contains(entryId) {
                    entryIds.append(entryId)
                    let encoder = JSONEncoder()
                    if let data = try? encoder.encode(entryIds) {
                        trip.entryIdsJSON = String(data: data, encoding: .utf8)
                    }
                }

                try context.save()
            }
        } catch {
            print("Failed to add entry to trip: \(error)")
        }
    }

    // MARK: - Visited Countries

    /// Fetch all visited countries
    func fetchVisitedCountries() -> [VisitedCountry] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredVisitedCountry>(
            sortBy: [SortDescriptor(\.firstVisitDate, order: .forward)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toVisitedCountry() }
        } catch {
            print("Failed to fetch visited countries: \(error)")
            return []
        }
    }

    /// Mark a country as visited
    func markCountryVisited(isoCode: String, name: String, region: String? = nil) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredVisitedCountry>(
            predicate: #Predicate { $0.isoCode == isoCode }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing - increment visit count
                existing.visitCount += 1
                if let region {
                    existing.addRegion(region)
                }
            } else {
                // Create new
                var regionsJSON: String? = nil
                if let region {
                    let encoder = JSONEncoder()
                    if let data = try? encoder.encode([region]) {
                        regionsJSON = String(data: data, encoding: .utf8)
                    }
                }

                let stored = StoredVisitedCountry(
                    isoCode: isoCode,
                    name: name,
                    firstVisitDate: Date(),
                    visitedRegionsJSON: regionsJSON,
                    visitCount: 1
                )
                context.insert(stored)
            }

            try context.save()
        } catch {
            print("Failed to mark country visited: \(error)")
        }
    }

    /// Check if a country has been visited
    func isCountryVisited(isoCode: String) -> Bool {
        guard let context = modelContext else { return false }

        var descriptor = FetchDescriptor<StoredVisitedCountry>(
            predicate: #Predicate { $0.isoCode == isoCode }
        )
        descriptor.fetchLimit = 1

        do {
            return try context.fetch(descriptor).first != nil
        } catch {
            print("Failed to check visited country: \(error)")
            return false
        }
    }

    // MARK: - Raw Locations (Background Tracking)

    /// Save a raw location from background tracking
    func saveRawLocation(latitude: Double, longitude: Double, accuracy: Double) {
        guard let context = modelContext else { return }

        let location = StoredRawLocation(
            latitude: latitude,
            longitude: longitude,
            timestamp: Date(),
            accuracy: accuracy,
            processed: false
        )

        context.insert(location)

        do {
            try context.save()
        } catch {
            print("Failed to save raw location: \(error)")
        }
    }

    /// Fetch unprocessed raw locations
    func fetchUnprocessedLocations() -> [StoredRawLocation] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredRawLocation>(
            predicate: #Predicate { $0.processed == false },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch unprocessed locations: \(error)")
            return []
        }
    }

    /// Mark locations as processed
    func markLocationsProcessed(_ locationIds: [String]) {
        guard let context = modelContext else { return }

        for id in locationIds {
            var descriptor = FetchDescriptor<StoredRawLocation>(
                predicate: #Predicate { $0.id == id }
            )
            descriptor.fetchLimit = 1

            do {
                if let location = try context.fetch(descriptor).first {
                    location.processed = true
                }
            } catch {
                print("Failed to mark location processed: \(error)")
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save processed locations: \(error)")
        }
    }

    // MARK: - Statistics

    /// Compute travel statistics
    func computeStats() -> TravelStats {
        let countries = fetchVisitedCountries()
        let entries = fetchJournalEntries()
        let trips = fetchTrips()

        let totalPhotos = entries.reduce(0) { $0 + $1.photos.count }
        let totalRegions = countries.reduce(0) { $0 + $1.visitedRegions.count }

        let flags = countries.map { $0.toFlag() }

        return TravelStats(
            countriesVisited: countries.count,
            regionsVisited: totalRegions,
            totalEntries: entries.count,
            totalPhotos: totalPhotos,
            totalTrips: trips.count,
            flagsCollected: flags,
            continentBreakdown: [:]  // TODO: Implement continent lookup
        )
    }
}
