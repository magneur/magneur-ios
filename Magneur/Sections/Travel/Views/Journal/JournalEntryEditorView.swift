//
//  JournalEntryEditorView.swift
//  Magneur
//
//  Created by Claude on 14.01.2026.
//

import SwiftUI
import MapKit
import PhotosUI
import CoreLocation
import Combine

/// View for creating or editing a journal entry
struct JournalEntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = JournalEntryEditorViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // Place selection section
                Section {
                    if let place = viewModel.selectedPlace {
                        selectedPlaceRow(place)
                    } else {
                        Button {
                            viewModel.showingPlaceSearch = true
                        } label: {
                            Label("Select a Place", systemImage: "mappin.circle")
                        }
                    }
                } header: {
                    Text("Location")
                } footer: {
                    Text("Search for a place or use your current location")
                }

                // Journal text section
                Section("Journal Entry") {
                    TextEditor(text: $viewModel.entryText)
                        .frame(minHeight: 150)
                }

                // Photos section
                Section {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotos,
                        maxSelectionCount: maxPhotosPerEntry - viewModel.photos.count,
                        matching: .images
                    ) {
                        Label(
                            viewModel.photos.isEmpty
                                ? "Add Photos"
                                : "Add More Photos (\(viewModel.remainingPhotoSlots) remaining)",
                            systemImage: "photo.badge.plus"
                        )
                    }
                    .disabled(!viewModel.canAddMorePhotos)

                    if !viewModel.photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.photos) { photo in
                                    photoThumbnail(photo)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } header: {
                    Text("Photos")
                } footer: {
                    Text("Add up to \(maxPhotosPerEntry) photos to your entry")
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveEntry()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $viewModel.showingPlaceSearch) {
                PlaceSearchView(selectedPlace: $viewModel.selectedPlace)
            }
            .onChange(of: viewModel.selectedPhotos) { _, newItems in
                Task {
                    await viewModel.loadSelectedPhotos(newItems)
                }
            }
        }
    }

    private func selectedPlaceRow(_ place: Place) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                Text(place.fullLocationDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.showingPlaceSearch = true
            } label: {
                Text("Change")
                    .font(.subheadline)
            }
        }
    }

    private func photoThumbnail(_ photo: JournalPhoto) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }

            Button {
                viewModel.removePhoto(photo)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white, .red)
                    .font(.title3)
            }
            .offset(x: 8, y: -8)
        }
    }
}

// MARK: - View Model

@MainActor
class JournalEntryEditorViewModel: ObservableObject {
    @Published var selectedPlace: Place?
    @Published var entryText: String = ""
    @Published var photos: [JournalPhoto] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var showingPlaceSearch: Bool = false

    var canSave: Bool {
        selectedPlace != nil
    }

    var canAddMorePhotos: Bool {
        photos.count < maxPhotosPerEntry
    }

    var remainingPhotoSlots: Int {
        max(0, maxPhotosPerEntry - photos.count)
    }

    func saveEntry() {
        guard let place = selectedPlace else { return }

        let entry = JournalEntry(
            text: entryText,
            photos: photos,
            place: place
        )

        TravelStore.shared.saveJournalEntry(entry)
    }

    func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let _ = try? await item.loadTransferable(type: Data.self) {
                let photo = JournalPhoto(
                    localIdentifier: item.itemIdentifier,
                    order: photos.count
                )
                photos.append(photo)
            }
        }
        selectedPhotos = []
    }

    func removePhoto(_ photo: JournalPhoto) {
        photos.removeAll { $0.id == photo.id }
        // Reorder remaining photos
        for (index, _) in photos.enumerated() {
            photos[index].order = index
        }
    }
}

// MARK: - Place Search View

/// View for searching and selecting a place
struct PlaceSearchView: View {
    @Binding var selectedPlace: Place?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PlaceSearchViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                // Current location option
                Section {
                    Button {
                        Task {
                            if let place = await viewModel.useCurrentLocation() {
                                selectedPlace = place
                                dismiss()
                            }
                        }
                    } label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Current Location")
                                if viewModel.isLoadingLocation {
                                    Text("Getting location...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "location.fill")
                        }
                    }
                    .disabled(viewModel.isLoadingLocation)
                }

                // Search results
                if !viewModel.searchResults.isEmpty {
                    Section("Search Results") {
                        ForEach(viewModel.searchResults, id: \.self) { mapItem in
                            Button {
                                selectMapItem(mapItem)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mapItem.name ?? "Unknown")
                                        .foregroundStyle(.primary)
                                    if let address = mapItem.address?.fullAddress {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a place")
            .onChange(of: searchText) { _, newValue in
                viewModel.search(query: newValue)
            }
            .navigationTitle("Select Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func selectMapItem(_ mapItem: MKMapItem) {
        let coordinate = mapItem.location.coordinate
        let address = mapItem.address

        // Use GeoService to look up country data from coordinates
        let countryFeature = GeoService.shared.findCountry(for: coordinate)

        let place = Place(
            name: mapItem.name ?? "Unknown Place",
            address: address?.fullAddress,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            countryCode: countryFeature?.properties.iso_a2,
            countryName: countryFeature?.properties.name,
            regionName: nil, // Not available in iOS 26 MKAddress
            locality: nil, // Not available in iOS 26 MKAddress
            category: categorizeMapItem(mapItem)
        )

        selectedPlace = place
        dismiss()
    }

    private func categorizeMapItem(_ mapItem: MKMapItem) -> PlaceCategory {
        guard let category = mapItem.pointOfInterestCategory else {
            return .other
        }

        switch category {
        case .restaurant:
            return .restaurant
        case .cafe:
            return .cafe
        case .nightlife:
            return .bar
        case .hotel:
            return .hotel
        case .museum:
            return .museum
        case .beach:
            return .beach
        case .nationalPark, .park:
            return .nature
        case .store:
            return .shopping
        default:
            return .touristAttraction
        }
    }
}

// MARK: - Place Search View Model

@MainActor
class PlaceSearchViewModel: ObservableObject {
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching = false
    @Published var isLoadingLocation = false

    private var searchTask: Task<Void, Never>?
    private let locationManager = CLLocationManager()

    func search(query: String) {
        searchTask?.cancel()

        guard !query.isEmpty else {
            searchResults = []
            return
        }

        searchTask = Task {
            isSearching = true
            defer { isSearching = false }

            // Small delay for debouncing
            try? await Task.sleep(nanoseconds: 300_000_000)

            guard !Task.isCancelled else { return }

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = [.pointOfInterest, .address]

            let search = MKLocalSearch(request: request)

            do {
                let response = try await search.start()
                if !Task.isCancelled {
                    searchResults = response.mapItems
                }
            } catch {
                print("Search failed: \(error)")
                searchResults = []
            }
        }
    }

    func useCurrentLocation() async -> Place? {
        isLoadingLocation = true
        defer { isLoadingLocation = false }

        // Request location permission if needed
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        // Get current location
        guard let location = locationManager.location else {
            return nil
        }

        // Use GeoService to look up country data from coordinates
        let countryFeature = GeoService.shared.findCountry(for: location.coordinate)

        // Reverse geocode using MKReverseGeocodingRequest
        guard let request = MKReverseGeocodingRequest(location: location) else {
            // Fallback if request creation fails
            return Place(
                name: "Current Location",
                address: nil,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                countryCode: countryFeature?.properties.iso_a2,
                countryName: countryFeature?.properties.name,
                regionName: nil,
                locality: nil,
                category: .other
            )
        }

        do {
            let mapItems = try await request.mapItems
            guard let mapItem = mapItems.first else {
                return Place(
                    name: "Current Location",
                    address: nil,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    countryCode: countryFeature?.properties.iso_a2,
                    countryName: countryFeature?.properties.name,
                    regionName: nil,
                    locality: nil,
                    category: .other
                )
            }

            return Place(
                name: mapItem.name ?? "Current Location",
                address: mapItem.address?.fullAddress,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                countryCode: countryFeature?.properties.iso_a2,
                countryName: countryFeature?.properties.name,
                regionName: nil,
                locality: nil,
                category: .other
            )
        } catch {
            print("Reverse geocoding failed: \(error)")
            return Place(
                name: "Current Location",
                address: nil,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                countryCode: countryFeature?.properties.iso_a2,
                countryName: countryFeature?.properties.name,
                regionName: nil,
                locality: nil,
                category: .other
            )
        }
    }
}

#Preview {
    JournalEntryEditorView()
}
