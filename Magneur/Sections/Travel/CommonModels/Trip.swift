//
//  Trip.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import Foundation

/// Represents a trip that groups multiple journal entries
struct Trip: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var startDate: Date
    var endDate: Date?
    var coverPhotoId: String?
    var entryIds: [String]
    var countriesVisited: [String]

    init(
        id: String = UUID().uuidString,
        name: String,
        startDate: Date = Date(),
        endDate: Date? = nil,
        coverPhotoId: String? = nil,
        entryIds: [String] = [],
        countriesVisited: [String] = []
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.coverPhotoId = coverPhotoId
        self.entryIds = entryIds
        self.countriesVisited = countriesVisited
    }

    /// Duration of the trip
    var duration: TimeInterval? {
        guard let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    /// Number of days in the trip
    var numberOfDays: Int? {
        guard let duration else { return nil }
        return Int(ceil(duration / 86400))
    }

    /// Whether the trip is currently active (no end date)
    var isActive: Bool {
        endDate == nil
    }

    /// Number of journal entries in this trip
    var entryCount: Int {
        entryIds.count
    }

    /// Number of countries visited during this trip
    var countryCount: Int {
        countriesVisited.count
    }

    /// Formatted date range string
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let startString = formatter.string(from: startDate)

        if let endDate {
            let endString = formatter.string(from: endDate)
            return "\(startString) - \(endString)"
        } else {
            return "\(startString) - Present"
        }
    }
}

extension Trip {
    /// JSON encoding for entryIds
    func getEntryIdsJSON() -> String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(entryIds) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    /// JSON encoding for countriesVisited
    func getCountriesVisitedJSON() -> String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(countriesVisited) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    /// Decode entryIds from JSON
    static func decodeEntryIds(from json: String?) -> [String] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    /// Decode countriesVisited from JSON
    static func decodeCountriesVisited(from json: String?) -> [String] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
