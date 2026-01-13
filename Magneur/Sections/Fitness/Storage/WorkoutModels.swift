//
//  WorkoutModels.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import Foundation
import SwiftData

/// Stored workout template/plan that can be executed
@Model
final class StoredWorkout {
    @Attribute(.unique) var id: String
    var name: String
    var workoutDescription: String?
    var startDate: Date?
    var exercisesJSON: String?
    var recurrenceString: String?
    var color: String?
    var iconName: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        workoutDescription: String? = nil,
        startDate: Date? = nil,
        exercisesJSON: String? = nil,
        recurrenceString: String? = nil,
        color: String? = nil,
        iconName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.workoutDescription = workoutDescription
        self.startDate = startDate
        self.exercisesJSON = exercisesJSON
        self.recurrenceString = recurrenceString
        self.color = color
        self.iconName = iconName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Convert to domain model
    func toWorkout() -> Workout {
        Workout(storedWorkout: self)
    }
}

/// Completed workout session with actual performance data
@Model
final class StoredCompletedWorkout {
    @Attribute(.unique) var id: String
    var workoutID: String?
    var name: String
    var workoutDescription: String?
    var startDate: Date?
    var endDate: Date?
    var exercisesJSON: String?
    var color: String?
    var iconName: String?
    
    init(
        id: String = UUID().uuidString,
        workoutID: String? = nil,
        name: String,
        workoutDescription: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        exercisesJSON: String? = nil,
        color: String? = nil,
        iconName: String? = nil
    ) {
        self.id = id
        self.workoutID = workoutID
        self.name = name
        self.workoutDescription = workoutDescription
        self.startDate = startDate
        self.endDate = endDate
        self.exercisesJSON = exercisesJSON
        self.color = color
        self.iconName = iconName
    }
    
    /// Convert to domain model
    func toCompletedWorkout() -> CompletedWorkout {
        CompletedWorkout(storedCompletedWorkout: self)
    }
}

// MARK: - Domain Model Extensions

extension Workout {
    init(storedWorkout: StoredWorkout) {
        self.id = storedWorkout.id
        self.name = storedWorkout.name
        self.workoutDescription = storedWorkout.workoutDescription
        self.startDate = storedWorkout.startDate
        self.exercises = Self.decodeExercises(from: storedWorkout.exercisesJSON)
        self.recurrenceString = storedWorkout.recurrenceString
        self.color = storedWorkout.color
        self.iconName = storedWorkout.iconName
    }
    
    private static func decodeExercises(from json: String?) -> [WorkoutExercise] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([WorkoutExercise].self, from: data)) ?? []
    }
    
    func toStoredWorkout() -> StoredWorkout {
        StoredWorkout(
            id: id ?? UUID().uuidString,
            name: name,
            workoutDescription: workoutDescription,
            startDate: startDate,
            exercisesJSON: getJsonForExercises(),
            recurrenceString: recurrenceString,
            color: color,
            iconName: iconName
        )
    }
}

extension CompletedWorkout {
    init(storedCompletedWorkout: StoredCompletedWorkout) {
        self.id = storedCompletedWorkout.id
        self.name = storedCompletedWorkout.name
        self.workoutDescription = storedCompletedWorkout.workoutDescription ?? ""
        self.startDate = storedCompletedWorkout.startDate
        self.endDate = storedCompletedWorkout.endDate
        self.exercises = Self.decodeExercises(from: storedCompletedWorkout.exercisesJSON)
        self.color = storedCompletedWorkout.color
        self.iconName = storedCompletedWorkout.iconName
    }
    
    private static func decodeExercises(from json: String?) -> [WorkoutExercise] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([WorkoutExercise].self, from: data)) ?? []
    }
    
    func toStoredCompletedWorkout() -> StoredCompletedWorkout {
        StoredCompletedWorkout(
            id: id ?? UUID().uuidString,
            workoutID: workoutID,
            name: name,
            workoutDescription: workoutDescription,
            startDate: startDate,
            endDate: endDate,
            exercisesJSON: getJsonForExercises(),
            color: color,
            iconName: iconName
        )
    }
}
