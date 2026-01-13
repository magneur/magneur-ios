//
//  ExerciseCatalog.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import Foundation
import HealthKit

/// Provides access to the exercise catalog
enum ExerciseCatalog {
    
    /// All available exercises
    static var allExercises: [Exercise] {
        commonExercises
    }
    
    /// Common exercises for quick access
    private static var commonExercises: [Exercise] {
        [
            // Barbell exercises
            Exercise(id: "benchPressBarbell", name: "Bench Press (Barbell)", description: "Classic chest builder", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
            Exercise(id: "squatBarbell", name: "Squat (Barbell)", description: "King of leg exercises", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
            Exercise(id: "deadliftBarbell", name: "Deadlift (Barbell)", description: "Full body compound lift", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
            Exercise(id: "overheadPressBarbell", name: "Overhead Press (Barbell)", description: "Shoulder strength builder", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
            Exercise(id: "rowBarbell", name: "Bent-Over Row (Barbell)", description: "Back thickness builder", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
            
            // Dumbbell exercises
            Exercise(id: "bicepCurlDumbbell", name: "Bicep Curl (Dumbbell)", description: "Classic arm exercise", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .dumbbell, executionType: .setsReps),
            Exercise(id: "lateralRaiseDumbbell", name: "Lateral Raise (Dumbbell)", description: "Shoulder isolation", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .dumbbell, executionType: .setsReps),
            Exercise(id: "rowDumbbell", name: "Row (Dumbbell)", description: "One-arm back exercise", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .dumbbell, executionType: .setsReps),
            Exercise(id: "chestPressDumbbell", name: "Chest Press (Dumbbell)", description: "Chest builder with dumbbells", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .dumbbell, executionType: .setsReps),
            Exercise(id: "lungesDumbbell", name: "Lunges (Dumbbell)", description: "Leg and glute exercise", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .dumbbell, executionType: .setsReps),
            
            // Bodyweight exercises
            Exercise(id: "pushup", name: "Push Up", description: "Classic bodyweight push", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "pullup", name: "Pull Up", description: "Upper body pull", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "chinup", name: "Chin Up", description: "Bicep-focused pull", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "dip", name: "Dip", description: "Tricep and chest exercise", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "squatBodyweight", name: "Squat (Bodyweight)", description: "Air squat", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "burpee", name: "Burpee", description: "Full body cardio exercise", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "plank", name: "Plank", description: "Core stability hold", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .timedSets),
            Exercise(id: "crunch", name: "Crunch", description: "Ab exercise", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "legRaiseFloor", name: "Leg Raise (Floor)", description: "Lower ab exercise", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
            
            // Machine exercises
            Exercise(id: "legPressMachine", name: "Leg Press (Machine)", description: "Quad builder", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
            Exercise(id: "legCurlMachine", name: "Leg Curl (Machine)", description: "Hamstring exercise", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
            Exercise(id: "legExtensionMachine", name: "Leg Extension (Machine)", description: "Quad isolation", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
            Exercise(id: "latPulldownMachine", name: "Lat Pulldown (Machine)", description: "Back width builder", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
            Exercise(id: "tricepPressdownMachine", name: "Tricep Pressdown (Machine)", description: "Tricep isolation", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
            Exercise(id: "cableRowMachine", name: "Cable Row (Machine)", description: "Back exercise", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
            
            // Cardio/Sport
            Exercise(id: "runningDistance", name: "Running for Distance", description: "Run a set distance", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
            Exercise(id: "runningTime", name: "Running for Time", description: "Run for a set duration", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .timedExercise),
            Exercise(id: "cycling", name: "Cycling", description: "Bike ride", sportCategory: .sport, sport: HKWorkoutActivityType.cycling.rawValue, category: .sport, executionType: .timedExercise),
            Exercise(id: "jumpRope", name: "Jump Rope", description: "Cardio with rope", sportCategory: .cardio, sport: HKWorkoutActivityType.jumpRope.rawValue, category: .other, executionType: .timedSets),
            
            // Mobility/Stretching
            Exercise(id: "hipCircles", name: "Hip Circles", description: "Hip mobility", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .setsReps),
            Exercise(id: "squatHold", name: "Squat Hold Stretch", description: "Deep squat hold", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .timedSets),
            Exercise(id: "standingPike", name: "Standing Pike", description: "Hamstring stretch", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .timedSets),
            Exercise(id: "catCow", name: "Cat-Cow Stretch", description: "Spine mobility", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .setsReps),
        ]
    }
}
