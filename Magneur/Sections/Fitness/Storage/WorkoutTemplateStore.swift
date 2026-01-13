//
//  WorkoutTemplateStore.swift
//  Magneur
//
//  Based on original by Andrei Istoc
//

import Foundation
import HealthKit

/// Categories of workout templates
enum WorkoutTemplateType: String, CaseIterable, Identifiable {
    case gymStrength = "Gym Strength"
    case calisthenics = "Calisthenics"
    case functionalFitness = "Functional Fitness"
    case running = "Running"
    case stretching = "Stretching"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .gymStrength: return "dumbbell.fill"
        case .calisthenics: return "figure.strengthtraining.traditional"
        case .functionalFitness: return "figure.highintensity.intervaltraining"
        case .running: return "figure.run"
        case .stretching: return "figure.flexibility"
        }
    }
}

/// Provides predefined workout templates
final class WorkoutTemplateStore {
    
    static let shared = WorkoutTemplateStore()
    
    let workoutTemplates: [WorkoutTemplateType: [Workout]]
    
    /// All templates as a flat array
    var allTemplates: [Workout] {
        workoutTemplates.values.flatMap { $0 }
    }
    
    private init() {
        workoutTemplates = [
            .gymStrength: Self.getGymStrengthTemplates(),
            .calisthenics: Self.getCalisthenicsTemplates(),
            .functionalFitness: Self.getFunctionalFitnessTemplates(),
            .running: Self.getRunningTemplates(),
            .stretching: Self.getStretchingTemplates(),
        ]
    }
    
    // MARK: - Gym Strength Templates
    
    private static func getGymStrengthTemplates() -> [Workout] {
        [
            // 5x5 Bench
            Workout(
                id: "5x5Bench",
                name: "5x5 Bench",
                workoutDescription: "Bench Press 5x5 Workout",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "benchPressBarbell", name: "Bench Press (Barbell)", description: "Classic chest builder", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
                        sets: (0..<5).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 75, rest: 180, timePerSet: 0, distance: 0) }
                    )
                ],
                color: "#9B1C1CFF",
                iconName: "bench-press"
            ),
            
            // 5x5 Deadlift
            Workout(
                id: "5x5Deadlift",
                name: "5x5 Deadlift",
                workoutDescription: "A quick deadlift workout in the popular 5x5 format",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "deadliftBarbell", name: "Deadlift (Barbell)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
                        sets: (0..<5).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 100, rest: 180, timePerSet: 0, distance: 0) }
                    )
                ],
                color: "#9B1C1CFF",
                iconName: "lifting"
            ),
            
            // 5x5 Back Squat
            Workout(
                id: "5x5BackSquat",
                name: "5x5 Back Squat",
                workoutDescription: "A quick squat workout in the popular 5x5 format",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBarbell", name: "Squat (Barbell)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
                        sets: (0..<5).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 100, rest: 180, timePerSet: 0, distance: 0) }
                    )
                ],
                color: "#9B1C1CFF",
                iconName: "lifting"
            ),
            
            // Push Workout
            Workout(
                id: "pushWeightWorkout",
                name: "Push Gym Workout",
                workoutDescription: "Work your chest and triceps using basic gym equipment",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "benchPressBarbell", name: "Bench Press (Barbell)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 75, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "overheadBarbellPress", name: "Overhead Press (Barbell)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 40, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "tricepPressdownMachine", name: "Tricep Pressdown (Machine)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 40, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                ],
                color: "#9B1C1CFF",
                iconName: "bench-press"
            ),
            
            // Pull Workout
            Workout(
                id: "pullWeightWorkout",
                name: "Pull Gym Workout",
                workoutDescription: "Work your back and biceps using basic gym equipment",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "pullup", name: "Pull Up", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 0, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "latPulldownMachine", name: "Lat Pulldown (Machine)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 8, weight: 40, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "bicepCurlDumbbell", name: "Bicep Curl (Dumbbell)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .dumbbell, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 8, weight: 12, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                ],
                color: "#9B1C1CFF",
                iconName: "weightlifting"
            ),
            
            // Legs Workout
            Workout(
                id: "legsWeightWorkout",
                name: "Legs Gym Workout",
                workoutDescription: "Work your legs using gym equipment",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBarbell", name: "Squat (Barbell)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .barbell, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 75, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "legPressMachine", name: "Leg Press (Machine)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 10, weight: 100, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "legCurlMachine", name: "Leg Curl (Machine)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 10, weight: 40, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "legExtensionMachine", name: "Leg Extension (Machine)", description: "", sportCategory: .weightlifting, sport: HKWorkoutActivityType.traditionalStrengthTraining.rawValue, category: .machine, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 10, weight: 40, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                ],
                color: "#9B1C1CFF",
                iconName: "lifting"
            ),
        ]
    }
    
    // MARK: - Calisthenics Templates
    
    private static func getCalisthenicsTemplates() -> [Workout] {
        [
            Workout(
                id: "pushUpWorkout",
                name: "Push-up Workout",
                workoutDescription: "5 sets of 10 push-ups",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "pushup", name: "Push Up", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: (0..<5).map { _ in ExerciseSet(id: UUID().uuidString, reps: 10, weight: 0, rest: 180, timePerSet: 0, distance: 0) }
                    )
                ],
                color: "#D50000FF",
                iconName: "squat"
            ),
            
            Workout(
                id: "airSquatWorkout",
                name: "Bodyweight Squat Workout",
                workoutDescription: "5 sets of 20 squats",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBodyWeight", name: "Squat (Bodyweight)", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: (0..<5).map { _ in ExerciseSet(id: UUID().uuidString, reps: 20, weight: 0, rest: 180, timePerSet: 0, distance: 0) }
                    )
                ],
                color: "#D50000FF",
                iconName: "squat"
            ),
            
            Workout(
                id: "calisthenicsBasicBackWorkout",
                name: "Basic Back Workout",
                workoutDescription: "Simple workout to develop back strength",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "chinup", name: "Chin Up", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 0, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "pullup", name: "Pull Up", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 5, weight: 0, rest: 180, timePerSet: 0, distance: 0) }
                    ),
                ],
                color: "#D50000FF",
                iconName: "squat"
            ),
            
            Workout(
                id: "calisthenicsAbBurner",
                name: "Quick Ab Calisthenics",
                workoutDescription: "Quick Ab Workout",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "legRaiseFloor", name: "Leg Raise (Floor)", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 10, weight: 0, rest: 60, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "crunch", name: "Crunch", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 10, weight: 0, rest: 60, timePerSet: 0, distance: 0) }
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "plank", name: "Plank", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .timedSets),
                        sets: (0..<3).map { _ in ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 60, timePerSet: 60, distance: 0) }
                    ),
                ],
                color: "#D50000FF",
                iconName: "lunge"
            ),
        ]
    }
    
    // MARK: - Running Templates
    
    private static func getRunningTemplates() -> [Workout] {
        [
            Workout(
                id: "400MeterBlast",
                name: "400 Meter Sprint",
                workoutDescription: "Train or test yourself on the 400 meter run",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 0, timePerSet: 0, distance: 400)]
                    )
                ],
                color: "#0E6B5AFF",
                iconName: "run"
            ),
            
            Workout(
                id: "5kRun",
                name: "5k Run",
                workoutDescription: "Train or test yourself on a 5 kilometer run",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 0, timePerSet: 0, distance: 5000)]
                    )
                ],
                color: "#0E6B5AFF",
                iconName: "run"
            ),
            
            Workout(
                id: "5x100MeterSprints",
                name: "100 Meter Sprints",
                workoutDescription: "5 Sprints of 100 meters",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: (0..<5).map { _ in ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 180, timePerSet: 0, distance: 100) }
                    )
                ],
                color: "#0E6B5AFF",
                iconName: "run"
            ),
            
            Workout(
                id: "10MinRun",
                name: "10 Minute Run",
                workoutDescription: "How far can you run in 10 minutes?",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "runningTime", name: "Running for Time", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .timedExercise),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 0, timePerSet: 600, distance: 0)]
                    )
                ],
                color: "#0E6B5AFF",
                iconName: "run"
            ),
        ]
    }
    
    // MARK: - Stretching Templates
    
    private static func getStretchingTemplates() -> [Workout] {
        [
            Workout(
                id: "dailyStretch",
                name: "Daily Stretch",
                workoutDescription: "Daily routine for limbering up",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "hipCircles", name: "Hip Circles", description: "", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 20, weight: 0, rest: 0, timePerSet: 0, distance: 0)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "squatHold", name: "Squat Hold Stretch", description: "", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .timedSets),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 0, timePerSet: 120, distance: 0)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "sealStretch", name: "Seal Stretch", description: "", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .timedSets),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 0, timePerSet: 120, distance: 0)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "standingPike", name: "Standing Pike", description: "", sportCategory: .mobility, sport: HKWorkoutActivityType.flexibility.rawValue, category: .bodyweight, executionType: .timedSets),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 0, timePerSet: 120, distance: 0)]
                    ),
                ],
                color: "#4C168DFF",
                iconName: "yoga"
            ),
        ]
    }
    
    // MARK: - Functional Fitness Templates
    
    private static func getFunctionalFitnessTemplates() -> [Workout] {
        [
            Workout(
                id: "runnersCombo",
                name: "Runner's Combo",
                workoutDescription: "Runs'n'Squats",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 60, timePerSet: 0, distance: 400)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBodyWeight", name: "Squat (Bodyweight)", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 20, weight: 0, rest: 300, timePerSet: 0, distance: 0)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 60, timePerSet: 0, distance: 400)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBodyWeight", name: "Squat (Bodyweight)", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 20, weight: 0, rest: 0, timePerSet: 0, distance: 0)]
                    ),
                ],
                color: "#2A6689FF",
                iconName: "run"
            ),
            
            Workout(
                id: "sprintCombo",
                name: "Sprint Combo",
                workoutDescription: "Sprints'n'Squats",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 180, timePerSet: 0, distance: 100)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBodyWeight", name: "Squat (Bodyweight)", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 20, weight: 0, rest: 180, timePerSet: 0, distance: 0)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 180, timePerSet: 0, distance: 100)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBodyWeight", name: "Squat (Bodyweight)", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 20, weight: 0, rest: 180, timePerSet: 0, distance: 0)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "runningDistance", name: "Running for Distance", description: "", sportCategory: .sport, sport: HKWorkoutActivityType.running.rawValue, category: .sport, executionType: .distance),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 0, weight: 0, rest: 180, timePerSet: 0, distance: 100)]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(id: "squatBodyWeight", name: "Squat (Bodyweight)", description: "", sportCategory: .fitness, sport: HKWorkoutActivityType.functionalStrengthTraining.rawValue, category: .bodyweight, executionType: .setsReps),
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 20, weight: 0, rest: 0, timePerSet: 0, distance: 0)]
                    ),
                ],
                color: "#2A6689FF",
                iconName: "run"
            ),
        ]
    }
}
