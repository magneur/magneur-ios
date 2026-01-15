//
//  GeoService.swift
//  Magneur
//
//  Ported from magneur-travel-ios on 14.01.2026.
//

import Foundation
import MapKit
import Combine

/// Service for loading and querying geographic data
@MainActor
class GeoService: ObservableObject {
    static let shared = GeoService()

    @Published var countries: GeoRegion?
    @Published var isLoading = false
    @Published var isDataLoaded = false

    private init() {
        Task {
            await loadGeoData()
        }
    }

    func loadGeoData() async {
        await MainActor.run {
            isLoading = true
        }
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }

        // Get all available geojson files
        let geojsonPaths = Bundle.main.paths(forResourcesOfType: "geojson", inDirectory: nil)

        // Find countries file
        let countriesPath = geojsonPaths.first(where: { $0.contains("ne_50m_admin_0_countries") })

        if let countriesPath = countriesPath {
            do {
                let countriesData = try Data(contentsOf: URL(fileURLWithPath: countriesPath))
                let decodedCountries = try JSONDecoder().decode(GeoRegion.self, from: countriesData)

                await MainActor.run {
                    self.countries = decodedCountries
                    self.isDataLoaded = true
                }
            } catch {
                print("Error loading GeoJSON: \(error)")
            }
        } else {
            print("GeoJSON file not found in bundle")
        }
    }

    /// Find the country containing a coordinate
    func findCountry(for coordinate: CLLocationCoordinate2D) -> GeoRegion.Feature? {
        guard isDataLoaded, let countriesData = countries else {
            return nil
        }

        let testPoint = MKMapPoint(coordinate)

        for country in countriesData.features {
            guard let polygon = country.polygon else { continue }

            let renderer = MKPolygonRenderer(polygon: polygon)
            let pointInRenderer = renderer.point(for: testPoint)

            let containsEvenOdd = renderer.path.contains(pointInRenderer, using: .evenOdd)
            let containsWinding = renderer.path.contains(pointInRenderer, using: .winding)

            if containsEvenOdd || containsWinding {
                return country
            }
        }

        return nil
    }

    /// Find a country by exact name match
    func findCountryByName(_ name: String) -> GeoRegion.Feature? {
        guard let countries = countries else { return nil }

        return countries.features.first {
            $0.properties.name.lowercased() == name.lowercased()
        }
    }

    /// Find a country by ISO code
    func findCountryByCode(_ isoCode: String) -> GeoRegion.Feature? {
        guard let countries = countries else { return nil }

        return countries.features.first {
            $0.properties.iso_a2?.lowercased() == isoCode.lowercased()
        }
    }

    /// Get all visited country overlays
    func getVisitedCountryOverlays() -> [RegionOverlay] {
        guard isDataLoaded, let countriesData = countries else {
            return []
        }

        let visitedCountries = TravelStore.shared.fetchVisitedCountries()
        let visitedCodes = Set(visitedCountries.map { $0.isoCode.lowercased() })

        var overlays: [RegionOverlay] = []

        for country in countriesData.features {
            guard let polygon = country.polygon,
                  let isoCode = country.properties.iso_a2?.lowercased(),
                  visitedCodes.contains(isoCode) else {
                continue
            }

            let overlay = RegionOverlay(
                polygon: polygon,
                properties: country.properties,
                isSubregion: false,
                isVisited: true
            )
            overlays.append(overlay)
        }

        return overlays
    }
}
