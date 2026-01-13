//
//  HealthKitManager.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import Foundation
import HealthKit

/// Manages HealthKit integration for workout data
@MainActor
final class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private var isAuthorized = false
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Request HealthKit authorization for workout data
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType()
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            isAuthorized = true
            return true
        } catch {
            print("HealthKit authorization failed: \(error)")
            return false
        }
    }
    
    // MARK: - Save Workout
    
    /// Save a completed workout to HealthKit
    func saveWorkout(workout: Workout, startTime: Date, endTime: Date) async {
        if !isAuthorized {
            let authorized = await requestAuthorization()
            if !authorized {
                print("HealthKit not authorized")
                return
            }
        }
        
        // Determine workout activity type
        let activityType = determineActivityType(for: workout)
        
        let hkWorkout = HKWorkout(
            activityType: activityType,
            start: startTime,
            end: endTime,
            workoutEvents: nil,
            totalEnergyBurned: nil,
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "Magneur",
                "WorkoutName": workout.name
            ]
        )
        
        do {
            try await healthStore.save(hkWorkout)
            print("Workout saved to HealthKit: \(workout.name)")
        } catch {
            print("Failed to save workout to HealthKit: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func determineActivityType(for workout: Workout) -> HKWorkoutActivityType {
        // Check the first exercise's sport category to determine type
        guard let firstExercise = workout.exercises.first else {
            return .traditionalStrengthTraining
        }
        
        // Use the stored sport value from the exercise
        if let activityType = HKWorkoutActivityType(rawValue: firstExercise.exercise.sport) {
            return activityType
        }
        
        // Fallback based on category
        switch firstExercise.exercise.sportCategory {
        case .weightlifting:
            return .traditionalStrengthTraining
        case .fitness, .other:
            return .functionalStrengthTraining
        case .cardio:
            return .running
        case .sport:
            if firstExercise.exercise.name.lowercased().contains("run") {
                return .running
            }
            return .other
        case .mobility:
            return .flexibility
        }
    }
}
