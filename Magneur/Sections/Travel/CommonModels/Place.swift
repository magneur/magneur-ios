//
//  Place.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import Foundation
import CoreLocation

/// Category of a place/POI
enum PlaceCategory: String, Codable, CaseIterable, Identifiable {
    case touristAttraction = "Tourist Attraction"
    case restaurant = "Restaurant"
    case hotel = "Hotel"
    case landmark = "Landmark"
    case nature = "Nature"
    case museum = "Museum"
    case beach = "Beach"
    case cafe = "Cafe"
    case bar = "Bar"
    case shopping = "Shopping"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .touristAttraction: return "star.fill"
        case .restaurant: return "fork.knife"
        case .hotel: return "bed.double.fill"
        case .landmark: return "building.columns.fill"
        case .nature: return "leaf.fill"
        case .museum: return "building.2.fill"
        case .beach: return "beach.umbrella.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .bar: return "wineglass.fill"
        case .shopping: return "bag.fill"
        case .other: return "mappin.circle.fill"
        }
    }
}

/// Represents a place or point of interest
struct Place: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var countryCode: String?
    var countryName: String?
    var regionName: String?
    var locality: String?
    var category: PlaceCategory?

    init(
        id: String = UUID().uuidString,
        name: String,
        address: String? = nil,
        latitude: Double,
        longitude: Double,
        countryCode: String? = nil,
        countryName: String? = nil,
        regionName: String? = nil,
        locality: String? = nil,
        category: PlaceCategory? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.countryCode = countryCode
        self.countryName = countryName
        self.regionName = regionName
        self.locality = locality
        self.category = category
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Short location description (locality, country)
    var shortLocationDescription: String {
        [locality, countryName].compactMap { $0 }.joined(separator: ", ")
    }

    /// Full location description
    var fullLocationDescription: String {
        [locality, regionName, countryName].compactMap { $0 }.joined(separator: ", ")
    }
}

