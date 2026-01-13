//
//  WorkoutDetailView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Pre-workout detail view showing exercises and allowing workout start
struct WorkoutDetailView: View {
    let workout: Workout
    
    @State private var showingExecution = false
    @State private var showingEdit = false
    @Environment(\.dismiss) private var dismiss
    
    private var isTemplate: Bool {
        // Templates have predefined IDs from WorkoutTemplateStore
        WorkoutTemplateStore.shared.allTemplates.contains { $0.id == workout.id }
    }
    
    private var gradientColors: [Color] {
        if let colorHex = workout.color {
            let color = Color(hex: colorHex) ?? .orange
            return [color.opacity(0.8), color.opacity(0.4)]
        }
        return [.orange.opacity(0.8), .red.opacity(0.4)]
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        if let description = workout.workoutDescription, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        HStack(spacing: 16) {
                            Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                            Label("\(totalSets) sets", systemImage: "repeat")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                    
                    // Exercises List
                    VStack(spacing: 12) {
                        ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, exercise in
                            ExercisePreviewRow(
                                index: index + 1,
                                workoutExercise: exercise
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            
            // Start button
            VStack {
                Spacer()
                
                Button {
                    showingExecution = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Workout")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    )
                }
                .padding()
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !isTemplate {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEdit = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showingExecution) {
            WorkoutExecutionView(workout: workout)
        }
        .sheet(isPresented: $showingEdit) {
            WorkoutCreationView(existingWorkout: workout)
        }
    }
    
    private var totalSets: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
}

// MARK: - Exercise Preview Row

struct ExercisePreviewRow: View {
    let index: Int
    let workoutExercise: WorkoutExercise
    
    var body: some View {
        HStack(spacing: 16) {
            // Index
            Text("\(index)")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workoutExercise.exercise.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(setsDescription)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Category icon
            categoryIcon
                .font(.title2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial.opacity(0.3))
        )
    }
    
    private var setsDescription: String {
        let setsCount = workoutExercise.sets.count
        
        switch workoutExercise.exercise.executionType {
        case .setsReps:
            if let firstSet = workoutExercise.sets.first {
                if firstSet.weight > 0 {
                    return "\(setsCount) × \(firstSet.reps) reps @ \(Int(firstSet.weight))kg"
                } else {
                    return "\(setsCount) × \(firstSet.reps) reps"
                }
            }
        case .timedSets:
            if let firstSet = workoutExercise.sets.first {
                return "\(setsCount) × \(formatTime(firstSet.timePerSet))"
            }
        case .timedExercise:
            if let firstSet = workoutExercise.sets.first {
                return formatTime(firstSet.timePerSet)
            }
        case .distance:
            if let firstSet = workoutExercise.sets.first {
                return formatDistance(firstSet.distance)
            }
        case .open:
            return "\(setsCount) sets"
        }
        
        return "\(setsCount) sets"
    }
    
    @ViewBuilder
    private var categoryIcon: some View {
        switch workoutExercise.exercise.category {
        case .barbell:
            Image(systemName: "dumbbell.fill")
        case .dumbbell:
            Image(systemName: "dumbbell")
        case .bodyweight:
            Image(systemName: "figure.strengthtraining.traditional")
        case .machine:
            Image(systemName: "gearshape.fill")
        case .kettlebell:
            Image(systemName: "scalemass.fill")
        case .resistanceBand:
            Image(systemName: "waveform")
        case .sport, .duration, .other:
            Image(systemName: "figure.run")
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        if seconds >= 60 {
            let mins = seconds / 60
            let secs = seconds % 60
            return secs > 0 ? "\(mins)m \(secs)s" : "\(mins) min"
        }
        return "\(seconds)s"
    }
    
    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 {
            let km = Double(meters) / 1000.0
            return String(format: "%.1f km", km)
        }
        return "\(meters)m"
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout(
            id: "test",
            name: "Push Workout",
            workoutDescription: "Work your chest and triceps",
            exercises: [
                WorkoutExercise(
                    exercise: Exercise(id: "benchPress", name: "Bench Press", description: "", sportCategory: .weightlifting, sport: 0, category: .barbell, executionType: .setsReps),
                    sets: [
                        ExerciseSet(id: "1", reps: 5, weight: 75, rest: 180, timePerSet: 0, distance: 0),
                        ExerciseSet(id: "2", reps: 5, weight: 75, rest: 180, timePerSet: 0, distance: 0),
                        ExerciseSet(id: "3", reps: 5, weight: 75, rest: 180, timePerSet: 0, distance: 0),
                    ]
                )
            ],
            color: "#9B1C1CFF"
        ))
    }
}
