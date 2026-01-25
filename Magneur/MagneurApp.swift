//
//  MagneurApp.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI
import SwiftData

@main
struct MagneurApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // Fitness models
            StoredWorkout.self,
            StoredCompletedWorkout.self,
            // Travel models
            StoredJournalEntry.self,
            StoredTrip.self,
            StoredVisitedCountry.self,
            StoredRawLocation.self,
            // Journal models
            StoredMindsetEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onAppear {
                    WorkoutStore.shared.configure(with: sharedModelContainer.mainContext)
                    TravelStore.shared.configure(with: sharedModelContainer.mainContext)
                    JournalStore.shared.configure(with: sharedModelContainer.mainContext)
                }
        }
    }
}
