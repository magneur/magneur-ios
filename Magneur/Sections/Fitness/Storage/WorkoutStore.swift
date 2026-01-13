//
//  WorkoutStore.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import Foundation
import SwiftData
import Observation

/// Manages workout persistence using SwiftData with CloudKit sync
@Observable
final class WorkoutStore {
    
    static let shared = WorkoutStore()
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    /// Configure with the app's model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Workouts
    
    /// Fetch all saved workouts
    func fetchWorkouts() -> [Workout] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<StoredWorkout>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toWorkout() }
        } catch {
            print("Failed to fetch workouts: \(error)")
            return []
        }
    }
    
    /// Save a new or update existing workout
    func saveWorkout(_ workout: Workout) {
        guard let context = modelContext else { return }
        
        let id = workout.id ?? UUID().uuidString
        
        // Check if exists
        var descriptor = FetchDescriptor<StoredWorkout>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.name = workout.name
                existing.workoutDescription = workout.workoutDescription
                existing.startDate = workout.startDate
                existing.exercisesJSON = workout.getJsonForExercises()
                existing.recurrenceString = workout.recurrenceString
                existing.color = workout.color
                existing.iconName = workout.iconName
                existing.updatedAt = Date()
            } else {
                // Create new
                var mutableWorkout = workout
                mutableWorkout.id = id
                context.insert(mutableWorkout.toStoredWorkout())
            }
            
            try context.save()
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
    
    /// Delete a workout
    func deleteWorkout(_ workout: Workout) {
        guard let context = modelContext, let id = workout.id else { return }
        
        var descriptor = FetchDescriptor<StoredWorkout>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
    
    // MARK: - Completed Workouts
    
    /// Record a completed workout session
    func completeWorkout(workout: Workout, startTime: Date, endTime: Date = Date()) {
        guard let context = modelContext else { return }
        
        let completed = StoredCompletedWorkout(
            workoutID: workout.id,
            name: workout.name,
            workoutDescription: workout.workoutDescription,
            startDate: startTime,
            endDate: endTime,
            exercisesJSON: workout.getJsonForExercises(),
            color: workout.color,
            iconName: workout.iconName
        )
        
        context.insert(completed)
        
        do {
            try context.save()
        } catch {
            print("Failed to save completed workout: \(error)")
        }
    }
    
    /// Fetch all completed workouts
    func fetchCompletedWorkouts() -> [CompletedWorkout] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<StoredCompletedWorkout>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toCompletedWorkout() }
        } catch {
            print("Failed to fetch completed workouts: \(error)")
            return []
        }
    }
    
    /// Delete a completed workout record
    func deleteCompletedWorkout(_ workout: CompletedWorkout) {
        guard let context = modelContext, let id = workout.id else { return }
        
        var descriptor = FetchDescriptor<StoredCompletedWorkout>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete completed workout: \(error)")
        }
    }
    
    /// Update a completed workout (e.g., after editing)
    func updateCompletedWorkout(_ workout: CompletedWorkout) {
        guard let context = modelContext, let id = workout.id else { return }
        
        var descriptor = FetchDescriptor<StoredCompletedWorkout>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(descriptor).first {
                existing.name = workout.name
                existing.workoutDescription = workout.workoutDescription
                existing.startDate = workout.startDate
                existing.endDate = workout.endDate
                existing.exercisesJSON = workout.getJsonForExercises()
                existing.color = workout.color
                existing.iconName = workout.iconName
                try context.save()
            }
        } catch {
            print("Failed to update completed workout: \(error)")
        }
    }
}
