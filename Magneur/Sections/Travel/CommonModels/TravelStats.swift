//
//  TravelStats.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import Foundation

/// Represents a country flag collected by visiting
struct CountryFlag: Identifiable, Codable, Hashable {
    var isoCode: String
    var name: String
    var firstVisitDate: Date

    var id: String { isoCode }

    /// Emoji flag for the country
    var emoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in isoCode.uppercased().unicodeScalars {
            if let unicodeScalar = UnicodeScalar(base + scalar.value) {
                emoji.append(Character(unicodeScalar))
            }
        }
        return emoji.isEmpty ? "🏳️" : emoji
    }
}

/// Computed travel statistics
struct TravelStats {
    let countriesVisited: Int
    let regionsVisited: Int
    let totalEntries: Int
    let totalPhotos: Int
    let totalTrips: Int
    let percentWorldExplored: Double
    let flagsCollected: [CountryFlag]
    let continentBreakdown: [String: Int]

    /// Total countries in the world (UN member states + observers)
    static let totalCountriesInWorld = 195

    init(
        countriesVisited: Int = 0,
        regionsVisited: Int = 0,
        totalEntries: Int = 0,
        totalPhotos: Int = 0,
        totalTrips: Int = 0,
        flagsCollected: [CountryFlag] = [],
        continentBreakdown: [String: Int] = [:]
    ) {
        self.countriesVisited = countriesVisited
        self.regionsVisited = regionsVisited
        self.totalEntries = totalEntries
        self.totalPhotos = totalPhotos
        self.totalTrips = totalTrips
        self.percentWorldExplored = Double(countriesVisited) / Double(Self.totalCountriesInWorld) * 100
        self.flagsCollected = flagsCollected
        self.continentBreakdown = continentBreakdown
    }

    /// Empty stats
    static let empty = TravelStats()
}

/// Represents a visited country with its regions
struct VisitedCountry: Identifiable, Codable, Hashable {
    var isoCode: String
    var name: String
    var firstVisitDate: Date
    var visitedRegions: [String]
    var visitCount: Int

    var id: String { isoCode }

    init(
        isoCode: String,
        name: String,
        firstVisitDate: Date = Date(),
        visitedRegions: [String] = [],
        visitCount: Int = 1
    ) {
        self.isoCode = isoCode
        self.name = name
        self.firstVisitDate = firstVisitDate
        self.visitedRegions = visitedRegions
        self.visitCount = visitCount
    }

    /// Emoji flag for the country
    var emoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in isoCode.uppercased().unicodeScalars {
            if let unicodeScalar = UnicodeScalar(base + scalar.value) {
                emoji.append(Character(unicodeScalar))
            }
        }
        return emoji.isEmpty ? "🏳️" : emoji
    }

    /// Convert to CountryFlag
    func toFlag() -> CountryFlag {
        CountryFlag(
            isoCode: isoCode,
            name: name,
            firstVisitDate: firstVisitDate
        )
    }
}
