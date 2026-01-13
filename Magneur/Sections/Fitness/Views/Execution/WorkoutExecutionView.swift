//
//  WorkoutExecutionView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Active workout execution screen with timer and set tracking
struct WorkoutExecutionView: View {
    let workout: Workout
    
    @StateObject private var stateManager: WorkoutStateManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingExitConfirmation = false
    
    init(workout: Workout) {
        self.workout = workout
        self._stateManager = StateObject(wrappedValue: WorkoutStateManager(workout: workout))
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if stateManager.isComplete {
                WorkoutCompletionView(
                    workout: workout,
                    duration: stateManager.elapsedTime,
                    onSave: {
                        stateManager.saveWorkout()
                        dismiss()
                    },
                    onDiscard: {
                        dismiss()
                    }
                )
            } else {
                VStack(spacing: 0) {
                    // Top bar
                    topBar
                    
                    Spacer()
                    
                    // Main content
                    mainContent
                    
                    Spacer()
                    
                    // Controls
                    controlButtons
                        .padding(.bottom, 40)
                }
            }
        }
        .confirmationDialog("Exit Workout?", isPresented: $showingExitConfirmation) {
            Button("Save & Exit", role: nil) {
                stateManager.saveWorkout()
                dismiss()
            }
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Do you want to save your progress?")
        }
    }
    
    private var backgroundColors: [Color] {
        if stateManager.isResting {
            return [.blue.opacity(0.8), .cyan.opacity(0.6)]
        }
        if let colorHex = workout.color, let color = Color(hex: colorHex) {
            return [color.opacity(0.9), color.opacity(0.6)]
        }
        return [.orange.opacity(0.9), .red.opacity(0.6)]
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button {
                showingExitConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Circle().fill(.ultraThinMaterial.opacity(0.3)))
            }
            
            Spacer()
            
            // Elapsed time
            Text(formatDuration(stateManager.elapsedTime))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
                .monospacedDigit()
            
            Spacer()
            
            // Progress
            Text("\(stateManager.currentExerciseIndex + 1)/\(workout.exercises.count)")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(.ultraThinMaterial.opacity(0.3)))
        }
        .padding()
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 32) {
            if stateManager.isResting {
                // Rest view
                VStack(spacing: 16) {
                    Text("REST")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(formatDuration(stateManager.restTimeRemaining))
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    
                    if let nextExercise = stateManager.nextExercise {
                        Text("Up Next: \(nextExercise.exercise.name)")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            } else {
                // Exercise view
                VStack(spacing: 24) {
                    // Exercise name
                    Text(stateManager.currentExercise?.exercise.name ?? "")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    // Set info
                    if let currentSet = stateManager.currentSet {
                        VStack(spacing: 16) {
                            Text("Set \(stateManager.currentSetIndex + 1) of \(stateManager.currentExercise?.sets.count ?? 0)")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.7))
                            
                            // Target display based on execution type
                            targetDisplay(for: currentSet)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private func targetDisplay(for set: ExerciseSet) -> some View {
        let exerciseType = stateManager.currentExercise?.exercise.executionType ?? .setsReps
        
        switch exerciseType {
        case .setsReps:
            VStack(spacing: 8) {
                Text("\(set.reps)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("reps")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
                
                if set.weight > 0 {
                    Text("@ \(Int(set.weight)) kg")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            
        case .timedSets, .timedExercise:
            VStack(spacing: 8) {
                Text(formatDuration(stateManager.exerciseTimeRemaining > 0 ? stateManager.exerciseTimeRemaining : set.timePerSet))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                
                if stateManager.exerciseTimeRemaining > 0 {
                    Text("remaining")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
        case .distance:
            VStack(spacing: 8) {
                Text(formatDistance(set.distance))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("target distance")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
        case .open:
            Text("Complete when ready")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 24) {
            if stateManager.isResting {
                // Skip rest button
                Button {
                    stateManager.skipRest()
                } label: {
                    Text("Skip Rest")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.4))
                        )
                }
            } else {
                // Complete set button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        stateManager.completeSet()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("Complete Set")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.green.opacity(0.8))
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", Double(meters) / 1000.0)
        }
        return "\(meters)m"
    }
}

#Preview {
    WorkoutExecutionView(workout: WorkoutTemplateStore.shared.allTemplates.first!)
}
