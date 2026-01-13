//
//  WorkoutStateManager.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import Foundation
import Combine

/// Manages workout execution state including timers and progress
@MainActor
final class WorkoutStateManager: ObservableObject {
    // MARK: - Published State
    
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0
    @Published var isResting: Bool = false
    @Published var restTimeRemaining: Int = 0
    @Published var exerciseTimeRemaining: Int = 0
    @Published var elapsedTime: Int = 0
    @Published var isComplete: Bool = false
    @Published var isPaused: Bool = false
    
    // MARK: - Properties
    
    let workout: Workout
    private let startTime: Date
    private var timer: Timer?
    private var timerCancellable: AnyCancellable?
    
    var currentExercise: WorkoutExercise? {
        guard currentExerciseIndex < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex]
    }
    
    var currentSet: ExerciseSet? {
        guard let exercise = currentExercise,
              currentSetIndex < exercise.sets.count else { return nil }
        return exercise.sets[currentSetIndex]
    }
    
    var nextExercise: WorkoutExercise? {
        guard currentExerciseIndex + 1 < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex + 1]
    }
    
    // MARK: - Init
    
    init(workout: Workout) {
        self.workout = workout
        self.startTime = Date()
        startTimers()
    }
    
    // MARK: - Timer Management
    
    private func startTimers() {
        // Elapsed time timer
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, !self.isPaused else { return }
                self.tick()
            }
    }
    
    private func stopTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func tick() {
        elapsedTime += 1
        
        if isResting && restTimeRemaining > 0 {
            restTimeRemaining -= 1
            if restTimeRemaining == 0 {
                endRest()
            }
        }
        
        if exerciseTimeRemaining > 0 {
            exerciseTimeRemaining -= 1
            if exerciseTimeRemaining == 0 {
                // Auto-complete timed exercises
                completeSet()
            }
        }
    }
    
    // MARK: - Actions
    
    func completeSet() {
        guard let exercise = currentExercise else { return }
        
        // Check if there are more sets in current exercise
        if currentSetIndex + 1 < exercise.sets.count {
            // Move to next set
            let restTime = currentSet?.rest ?? 0
            currentSetIndex += 1
            
            if restTime > 0 {
                startRest(duration: restTime)
            } else {
                prepareForNextSet()
            }
        } else {
            // Move to next exercise
            if currentExerciseIndex + 1 < workout.exercises.count {
                let restTime = currentSet?.rest ?? 0
                currentExerciseIndex += 1
                currentSetIndex = 0
                
                if restTime > 0 {
                    startRest(duration: restTime)
                } else {
                    prepareForNextSet()
                }
            } else {
                // Workout complete
                completeWorkout()
            }
        }
    }
    
    func skipRest() {
        endRest()
    }
    
    private func startRest(duration: Int) {
        isResting = true
        restTimeRemaining = duration
    }
    
    private func endRest() {
        isResting = false
        restTimeRemaining = 0
        prepareForNextSet()
    }
    
    private func prepareForNextSet() {
        // Start timer for timed exercises
        if let exercise = currentExercise,
           let set = currentSet,
           exercise.exercise.executionType == .timedSets || exercise.exercise.executionType == .timedExercise {
            exerciseTimeRemaining = set.timePerSet
        }
    }
    
    private func completeWorkout() {
        isComplete = true
        stopTimers()
    }
    
    func saveWorkout() {
        WorkoutStore.shared.completeWorkout(
            workout: workout,
            startTime: startTime,
            endTime: Date()
        )
        
        // Save to HealthKit
        Task {
            await HealthKitManager.shared.saveWorkout(
                workout: workout,
                startTime: startTime,
                endTime: Date()
            )
        }
    }
    
    func togglePause() {
        isPaused.toggle()
    }
}
