//
//  TravelModels.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import Foundation
import SwiftData

// MARK: - Stored Journal Entry

/// SwiftData model for journal entries
@Model
final class StoredJournalEntry {
    @Attribute(.unique) var id: String
    var text: String
    var photosJSON: String?
    var placeJSON: String?
    var createdAt: Date
    var updatedAt: Date
    var tripId: String?

    init(
        id: String = UUID().uuidString,
        text: String = "",
        photosJSON: String? = nil,
        placeJSON: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tripId: String? = nil
    ) {
        self.id = id
        self.text = text
        self.photosJSON = photosJSON
        self.placeJSON = placeJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tripId = tripId
    }

    /// Convert to domain model
    func toJournalEntry() -> JournalEntry? {
        guard let place = JournalEntry.decodePlace(from: placeJSON) else {
            return nil
        }

        return JournalEntry(
            id: id,
            text: text,
            photos: JournalEntry.decodePhotos(from: photosJSON),
            place: place,
            createdAt: createdAt,
            updatedAt: updatedAt,
            tripId: tripId
        )
    }
}

// MARK: - Stored Trip

/// SwiftData model for trips
@Model
final class StoredTrip {
    @Attribute(.unique) var id: String
    var name: String
    var startDate: Date
    var endDate: Date?
    var coverPhotoId: String?
    var entryIdsJSON: String?
    var countriesVisitedJSON: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        startDate: Date = Date(),
        endDate: Date? = nil,
        coverPhotoId: String? = nil,
        entryIdsJSON: String? = nil,
        countriesVisitedJSON: String? = nil
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.coverPhotoId = coverPhotoId
        self.entryIdsJSON = entryIdsJSON
        self.countriesVisitedJSON = countriesVisitedJSON
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Convert to domain model
    func toTrip() -> Trip {
        Trip(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            coverPhotoId: coverPhotoId,
            entryIds: Trip.decodeEntryIds(from: entryIdsJSON),
            countriesVisited: Trip.decodeCountriesVisited(from: countriesVisitedJSON)
        )
    }
}

// MARK: - Stored Visited Country

/// SwiftData model for tracking visited countries
@Model
final class StoredVisitedCountry {
    @Attribute(.unique) var isoCode: String
    var name: String
    var firstVisitDate: Date
    var visitedRegionsJSON: String?
    var visitCount: Int

    init(
        isoCode: String,
        name: String,
        firstVisitDate: Date = Date(),
        visitedRegionsJSON: String? = nil,
        visitCount: Int = 1
    ) {
        self.isoCode = isoCode
        self.name = name
        self.firstVisitDate = firstVisitDate
        self.visitedRegionsJSON = visitedRegionsJSON
        self.visitCount = visitCount
    }

    /// Convert to domain model
    func toVisitedCountry() -> VisitedCountry {
        let regions = decodeRegions()
        return VisitedCountry(
            isoCode: isoCode,
            name: name,
            firstVisitDate: firstVisitDate,
            visitedRegions: regions,
            visitCount: visitCount
        )
    }

    private func decodeRegions() -> [String] {
        guard let json = visitedRegionsJSON,
              let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    func addRegion(_ region: String) {
        var regions = decodeRegions()
        if !regions.contains(region) {
            regions.append(region)
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(regions) {
                visitedRegionsJSON = String(data: data, encoding: .utf8)
            }
        }
    }
}

// MARK: - Stored Raw Location (for background tracking)

/// SwiftData model for buffering raw location updates
@Model
final class StoredRawLocation {
    @Attribute(.unique) var id: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var accuracy: Double
    var processed: Bool

    init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        timestamp: Date = Date(),
        accuracy: Double = 0,
        processed: Bool = false
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.accuracy = accuracy
        self.processed = processed
    }
}

// MARK: - Domain Model Extensions

extension JournalEntry {
    init?(storedEntry: StoredJournalEntry) {
        guard let place = Self.decodePlace(from: storedEntry.placeJSON) else {
            return nil
        }

        self.id = storedEntry.id
        self.text = storedEntry.text
        self.photos = Self.decodePhotos(from: storedEntry.photosJSON)
        self.place = place
        self.createdAt = storedEntry.createdAt
        self.updatedAt = storedEntry.updatedAt
        self.tripId = storedEntry.tripId
    }

    func toStoredEntry() -> StoredJournalEntry {
        StoredJournalEntry(
            id: id,
            text: text,
            photosJSON: getPhotosJSON(),
            placeJSON: getPlaceJSON(),
            createdAt: createdAt,
            updatedAt: updatedAt,
            tripId: tripId
        )
    }
}

extension Trip {
    init(storedTrip: StoredTrip) {
        self.id = storedTrip.id
        self.name = storedTrip.name
        self.startDate = storedTrip.startDate
        self.endDate = storedTrip.endDate
        self.coverPhotoId = storedTrip.coverPhotoId
        self.entryIds = Self.decodeEntryIds(from: storedTrip.entryIdsJSON)
        self.countriesVisited = Self.decodeCountriesVisited(from: storedTrip.countriesVisitedJSON)
    }

    func toStoredTrip() -> StoredTrip {
        StoredTrip(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            coverPhotoId: coverPhotoId,
            entryIdsJSON: getEntryIdsJSON(),
            countriesVisitedJSON: getCountriesVisitedJSON()
        )
    }
}

extension VisitedCountry {
    init(storedCountry: StoredVisitedCountry) {
        self = storedCountry.toVisitedCountry()
    }

    func toStoredCountry() -> StoredVisitedCountry {
        let encoder = JSONEncoder()
        let regionsJSON = (try? encoder.encode(visitedRegions))
            .flatMap { String(data: $0, encoding: .utf8) }

        return StoredVisitedCountry(
            isoCode: isoCode,
            name: name,
            firstVisitDate: firstVisitDate,
            visitedRegionsJSON: regionsJSON,
            visitCount: visitCount
        )
    }
}
