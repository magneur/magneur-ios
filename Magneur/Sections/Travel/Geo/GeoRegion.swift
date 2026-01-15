//
//  GeoRegion.swift
//  Magneur
//
//  Ported from magneur-travel-ios on 14.01.2026.
//

import Foundation
import MapKit

struct GeoRegion: Codable {
    let type: String
    let features: [Feature]

    struct Feature: Codable {
        let type: String
        let properties: Properties
        let geometry: Geometry

        var polygon: MKPolygon? {
            guard let coordinates = try? getCoordinates() else {
                return nil
            }

            // For single polygons with simple structure
            if coordinates.count == 1 {
                let points = coordinates[0].map {
                    // GeoJSON has [longitude, latitude] format
                    return CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
                }

                if points.count > 2 {
                    let validPoints = points.filter {
                        return !$0.latitude.isNaN && !$0.longitude.isNaN &&
                               $0.latitude >= -90 && $0.latitude <= 90 &&
                               $0.longitude >= -180 && $0.longitude <= 180
                    }

                    if validPoints.count >= 3 {
                        return MKPolygon(coordinates: validPoints, count: validPoints.count)
                    }
                }
            }
            // For more complex multipolygons
            else if coordinates.count > 1 {
                var bestArray = coordinates[0]
                var maxPoints = bestArray.count

                for coordArray in coordinates {
                    if coordArray.count > maxPoints {
                        maxPoints = coordArray.count
                        bestArray = coordArray
                    }
                }

                let points = bestArray.map {
                    CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
                }

                let validPoints = points.filter {
                    return !$0.latitude.isNaN && !$0.longitude.isNaN &&
                           $0.latitude >= -90 && $0.latitude <= 90 &&
                           $0.longitude >= -180 && $0.longitude <= 180
                }

                if validPoints.count >= 3 {
                    return MKPolygon(coordinates: validPoints, count: validPoints.count)
                }
            }

            return nil
        }

        var centroid: CLLocationCoordinate2D? {
            guard let coordinates = try? getCoordinates(), coordinates.count > 0 else {
                return nil
            }

            let coordArray = coordinates[0]
            if coordArray.isEmpty {
                return nil
            }

            var totalLat: Double = 0
            var totalLng: Double = 0

            for coordinate in coordArray {
                if coordinate.count >= 2 {
                    totalLat += coordinate[1]
                    totalLng += coordinate[0]
                }
            }

            let count = Double(coordArray.count)

            if count > 0 {
                return CLLocationCoordinate2D(
                    latitude: totalLat / count,
                    longitude: totalLng / count
                )
            }

            return nil
        }

        private func getCoordinates() throws -> [[[Double]]] {
            switch geometry.type.lowercased() {
            case "polygon":
                if let coords = geometry.coordinates as? [[[Double]]] {
                    return coords
                } else if let coords = geometry.coordinates as? [[Double]] {
                    return [coords]
                }
                throw GeoError.invalidFormat

            case "multipolygon":
                if let multiCoords = geometry.coordinates as? [[[[Double]]]] {
                    let firstPolygons = multiCoords.compactMap { polygons -> [[Double]]? in
                        guard let firstRing = polygons.first else { return nil }
                        return firstRing
                    }
                    return firstPolygons
                } else if let coords = geometry.coordinates as? [[[Double]]] {
                    return coords
                }
                throw GeoError.invalidFormat

            default:
                if let coords = geometry.coordinates as? [[[Double]]] {
                    return coords
                } else if let coords = geometry.coordinates as? [[Double]] {
                    return [coords]
                }
                throw GeoError.unsupportedType
            }
        }
    }

    struct Properties: Codable {
        let name: String
        let admin: String?
        let iso_a2: String?

        enum CodingKeys: String, CodingKey {
            case name, NAME, admin, ADMIN, iso_a2, ISO_A2
            case name_long, name_en, nameascii
            case adm0_name, adm0_a3, admin0, sovereignt
            case sov_a3, abbrev, postal
            case name_sort, continent
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // Try different name fields
            if let value = try? container.decode(String.self, forKey: .name) {
                name = value
            } else if let value = try? container.decode(String.self, forKey: .NAME) {
                name = value
            } else if let value = try? container.decode(String.self, forKey: .name_long) {
                name = value
            } else if let value = try? container.decode(String.self, forKey: .name_en) {
                name = value
            } else if let value = try? container.decode(String.self, forKey: .adm0_name) {
                name = value
            } else if let value = try? container.decode(String.self, forKey: .sovereignt) {
                name = value
            } else if let value = try? container.decode(String.self, forKey: .name_sort) {
                name = value
            } else if let value = try? container.decode(String.self, forKey: .nameascii) {
                name = value
            } else {
                name = "Unknown"
            }

            // Try different admin fields
            if let value = try? container.decode(String.self, forKey: .admin) {
                admin = value
            } else if let value = try? container.decode(String.self, forKey: .ADMIN) {
                admin = value
            } else if let value = try? container.decode(String.self, forKey: .admin0) {
                admin = value
            } else if let value = try? container.decode(String.self, forKey: .sovereignt) {
                admin = value
            } else if let value = try? container.decode(String.self, forKey: .adm0_name) {
                admin = value
            } else {
                admin = nil
            }

            // Try different country code fields
            if let value = try? container.decode(String.self, forKey: .iso_a2) {
                iso_a2 = value
            } else if let value = try? container.decode(String.self, forKey: .ISO_A2) {
                iso_a2 = value
            } else if let value = try? container.decode(String.self, forKey: .adm0_a3) {
                iso_a2 = value
            } else if let value = try? container.decode(String.self, forKey: .sov_a3) {
                iso_a2 = value
            } else if let value = try? container.decode(String.self, forKey: .abbrev) {
                iso_a2 = value
            } else if let value = try? container.decode(String.self, forKey: .postal) {
                iso_a2 = value
            } else {
                iso_a2 = nil
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            if let admin = admin {
                try container.encode(admin, forKey: .admin)
            }
            if let iso_a2 = iso_a2 {
                try container.encode(iso_a2, forKey: .iso_a2)
            }
        }
    }

    struct Geometry: Codable {
        let type: String
        private(set) var coordinates: Any

        enum CodingKeys: String, CodingKey {
            case type, coordinates
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)

            switch type.lowercased() {
            case "point":
                coordinates = try container.decode([Double].self, forKey: .coordinates)

            case "polygon":
                do {
                    coordinates = try container.decode([[[Double]]].self, forKey: .coordinates)
                } catch {
                    do {
                        coordinates = try container.decode([[Double]].self, forKey: .coordinates)
                    } catch {
                        coordinates = [[Double]]()
                    }
                }

            case "multipolygon":
                do {
                    coordinates = try container.decode([[[[Double]]]].self, forKey: .coordinates)
                } catch {
                    do {
                        coordinates = try container.decode([[[Double]]].self, forKey: .coordinates)
                    } catch {
                        coordinates = [[[Double]]]()
                    }
                }

            default:
                do {
                    coordinates = try container.decode([[[Double]]].self, forKey: .coordinates)
                } catch {
                    do {
                        coordinates = try container.decode([[Double]].self, forKey: .coordinates)
                    } catch {
                        do {
                            coordinates = try container.decode([Double].self, forKey: .coordinates)
                        } catch {
                            coordinates = [[Double]]()
                        }
                    }
                }
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)

            if type == "Polygon" {
                if let coords = coordinates as? [[[Double]]] {
                    try container.encode(coords, forKey: .coordinates)
                } else if let coords = coordinates as? [[Double]] {
                    try container.encode(coords, forKey: .coordinates)
                } else {
                    try container.encode([[Double]](), forKey: .coordinates)
                }
            } else if type == "MultiPolygon" {
                if let coords = coordinates as? [[[[Double]]]] {
                    try container.encode(coords, forKey: .coordinates)
                } else if let coords = coordinates as? [[[Double]]] {
                    try container.encode(coords, forKey: .coordinates)
                } else {
                    try container.encode([[[Double]]](), forKey: .coordinates)
                }
            } else {
                try container.encode([[Double]](), forKey: .coordinates)
            }
        }
    }
}

// MARK: - Errors

enum GeoError: Error {
    case invalidFormat
    case unsupportedType
}

// MARK: - Region Overlay

class RegionOverlay: NSObject, MKOverlay {
    let polygon: MKPolygon
    let properties: GeoRegion.Properties?
    let isSubregion: Bool
    let isVisited: Bool

    init(polygon: MKPolygon, properties: GeoRegion.Properties?, isSubregion: Bool, isVisited: Bool = true) {
        self.polygon = polygon
        self.properties = properties
        self.isSubregion = isSubregion
        self.isVisited = isVisited
        super.init()
    }

    var coordinate: CLLocationCoordinate2D {
        return polygon.coordinate
    }

    var boundingMapRect: MKMapRect {
        return polygon.boundingMapRect
    }
}
