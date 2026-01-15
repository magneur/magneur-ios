//
//  TravelMapView.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import SwiftUI
import MapKit

/// Main travel map view showing visited countries/regions
struct TravelMapView: View {
    @StateObject private var geoService = GeoService.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
    )
    @State private var overlays: [RegionOverlay] = []

    var body: some View {
        ZStack {
            InteractiveMapView(
                region: $region,
                overlays: overlays,
                entries: TravelStore.shared.fetchJournalEntries()
            )
            .ignoresSafeArea()

            if geoService.isLoading {
                ProgressView("Loading map data...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .onAppear {
            loadOverlays()
        }
        .onReceive(geoService.$isDataLoaded) { isLoaded in
            if isLoaded {
                loadOverlays()
            }
        }
    }

    private func loadOverlays() {
        overlays = geoService.getVisitedCountryOverlays()
    }
}

/// UIViewRepresentable wrapper for MKMapView
struct InteractiveMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let overlays: [RegionOverlay]
    let entries: [JournalEntry]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        // Configure map style
        mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)

        // Update overlays
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlays(overlays)

        // Update annotations for journal entries
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)

        let annotations = entries.map { entry -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = entry.place.coordinate
            annotation.title = entry.place.name
            annotation.subtitle = entry.createdAt.formatted(date: .abbreviated, time: .omitted)
            return annotation
        }
        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: InteractiveMapView

        init(_ parent: InteractiveMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let regionOverlay = overlay as? RegionOverlay {
                let renderer = MKPolygonRenderer(polygon: regionOverlay.polygon)

                if regionOverlay.isVisited {
                    // Visited country - teal fill
                    renderer.fillColor = UIColor.systemTeal.withAlphaComponent(0.3)
                    renderer.strokeColor = UIColor.systemTeal.withAlphaComponent(0.7)
                } else {
                    // Unvisited - very subtle outline
                    renderer.fillColor = UIColor.clear
                    renderer.strokeColor = UIColor.gray.withAlphaComponent(0.2)
                }

                renderer.lineWidth = 1.5
                return renderer
            }

            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "journalEntry"
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ??
                MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            if let markerView = annotationView as? MKMarkerAnnotationView {
                markerView.markerTintColor = UIColor.systemCyan
                markerView.glyphImage = UIImage(systemName: "book.fill")
            }

            annotationView.canShowCallout = true
            return annotationView
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }
}

#Preview {
    TravelMapView()
}
