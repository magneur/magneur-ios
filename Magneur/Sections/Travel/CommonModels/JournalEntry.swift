//
//  JournalEntry.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import Foundation

/// Maximum number of photos allowed per journal entry
let maxPhotosPerEntry = 5

/// Represents a photo attached to a journal entry
struct JournalPhoto: Identifiable, Codable, Hashable {
    var id: String
    var localIdentifier: String?
    var caption: String?
    var order: Int

    init(
        id: String = UUID().uuidString,
        localIdentifier: String? = nil,
        caption: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.localIdentifier = localIdentifier
        self.caption = caption
        self.order = order
    }
}

/// Represents a travel journal entry
struct JournalEntry: Identifiable, Codable, Hashable {
    var id: String
    var text: String
    var photos: [JournalPhoto]
    var place: Place
    var createdAt: Date
    var updatedAt: Date
    var tripId: String?

    init(
        id: String = UUID().uuidString,
        text: String = "",
        photos: [JournalPhoto] = [],
        place: Place,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tripId: String? = nil
    ) {
        self.id = id
        self.text = text
        self.photos = photos
        self.place = place
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tripId = tripId
    }

    /// Photos sorted by order
    var sortedPhotos: [JournalPhoto] {
        photos.sorted { $0.order < $1.order }
    }

    /// First photo (cover photo)
    var coverPhoto: JournalPhoto? {
        sortedPhotos.first
    }

    /// Whether this entry has any photos
    var hasPhotos: Bool {
        !photos.isEmpty
    }

    /// Whether more photos can be added
    var canAddMorePhotos: Bool {
        photos.count < maxPhotosPerEntry
    }

    /// Number of photos that can still be added
    var remainingPhotoSlots: Int {
        max(0, maxPhotosPerEntry - photos.count)
    }
}

extension JournalEntry {
    /// JSON encoding for photos array
    func getPhotosJSON() -> String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(photos) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    /// JSON encoding for place
    func getPlaceJSON() -> String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(place) else { return "{}" }
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    /// Decode photos from JSON
    static func decodePhotos(from json: String?) -> [JournalPhoto] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([JournalPhoto].self, from: data)) ?? []
    }

    /// Decode place from JSON
    static func decodePlace(from json: String?) -> Place? {
        guard let json, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Place.self, from: data)
    }
}
