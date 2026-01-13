//
//  Workout.swift
//  Magneur Fitness
//
//  Created by Andrei Istoc on 08.06.2022.
//

import Foundation

struct WorkoutOccurrence {
    var workout: Workout
    var date: Date
}

// Weight is stored in kg
public class WorkoutExercise: Codable, Equatable {
    var exercise: Exercise
    var sets: [ExerciseSet] = []
    
    init(exercise: Exercise, sets: [ExerciseSet]) {
        self.exercise = exercise
        self.sets = sets
    }
    
    public static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        return lhs.exercise == rhs.exercise && lhs.sets == rhs.sets
    }
}

struct ExerciseSet: Equatable, Codable, Identifiable {
    var id: String
    var reps: Int
    var weight: Float // Kg
    var rest: Int
    var timePerSet: Int
    var distance: Int // Meters
}

struct Workout: Codable, Identifiable, Hashable {
    var id: String?
    var name: String
    var workoutDescription: String?
    var startDate: Date?
    var exercises: [WorkoutExercise] = [WorkoutExercise]()
    var recurrenceString: String?
    var color: String?
    var iconName: String?
    
    init(id: String? = nil, name: String, workoutDescription: String? = nil, startDate: Date? = nil, exercises: [WorkoutExercise], recurrenceString: String? = nil, color: String? = nil, iconName: String? = nil) {
        self.id = id
        self.name = name
        self.workoutDescription = workoutDescription
        self.startDate = startDate
        self.exercises = exercises
        self.recurrenceString = recurrenceString
        self.color = color
        self.iconName = iconName
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Workout {
    
    func getJsonForExercises() -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(self.exercises)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)!
        return json
    }
}

struct CompletedWorkout: Identifiable, Codable {
    var id: String?
    var startDate: Date?
    var endDate: Date?
    var workoutID: String?
    var name: String
    var workoutDescription: String
    var exercises: [WorkoutExercise] = [WorkoutExercise]()
    var color: String?
    var iconName: String?
    
    init(
        id: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        workoutID: String? = nil,
        name: String,
        workoutDescription: String = "",
        exercises: [WorkoutExercise] = [],
        color: String? = nil,
        iconName: String? = nil
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.workoutID = workoutID
        self.name = name
        self.workoutDescription = workoutDescription
        self.exercises = exercises
        self.color = color
        self.iconName = iconName
    }
    
    func getJsonForExercises() -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(self.exercises)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)!
        return json
    }
}

