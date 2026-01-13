//
//  WorkoutHistoryView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// View showing completed workout history
struct WorkoutHistoryView: View {
    @State private var completedWorkouts: [CompletedWorkout] = []
    @State private var selectedWorkout: CompletedWorkout?
    @Environment(\.dismiss) private var dismiss
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if completedWorkouts.isEmpty {
                    emptyState
                } else {
                    workoutList
                }
            }
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadHistory()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Workout History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Complete workouts to see them here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var workoutList: some View {
        List {
            ForEach(groupedWorkouts, id: \.key) { group in
                Section(header: Text(group.key)) {
                    ForEach(group.workouts) { workout in
                        HistoryWorkoutRow(workout: workout)
                            .onTapGesture {
                                selectedWorkout = workout
                            }
                    }
                    .onDelete { indexSet in
                        deleteWorkouts(in: group.workouts, at: indexSet)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $selectedWorkout) { workout in
            CompletedWorkoutDetailView(workout: workout)
        }
    }
    
    private var groupedWorkouts: [(key: String, workouts: [CompletedWorkout])] {
        let grouped = Dictionary(grouping: completedWorkouts) { workout -> String in
            guard let date = workout.startDate else { return "Unknown" }
            
            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
                return "This Week"
            } else if calendar.isDate(date, equalTo: Date(), toGranularity: .month) {
                return "This Month"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: date)
            }
        }
        
        // Sort by date (most recent first)
        let sortedKeys = ["Today", "Yesterday", "This Week", "This Month"] + 
            grouped.keys.filter { !["Today", "Yesterday", "This Week", "This Month"].contains($0) }.sorted().reversed()
        
        return sortedKeys.compactMap { key in
            guard let workouts = grouped[key] else { return nil }
            return (key: key, workouts: workouts.sorted { ($0.startDate ?? .distantPast) > ($1.startDate ?? .distantPast) })
        }
    }
    
    private func loadHistory() {
        completedWorkouts = WorkoutStore.shared.fetchCompletedWorkouts()
    }
    
    private func deleteWorkouts(in workouts: [CompletedWorkout], at indexSet: IndexSet) {
        for index in indexSet {
            let workout = workouts[index]
            WorkoutStore.shared.deleteCompletedWorkout(workout)
        }
        loadHistory()
    }
}

// MARK: - History Workout Row

struct HistoryWorkoutRow: View {
    let workout: CompletedWorkout
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: workout.color ?? "#FF5722") ?? .orange)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if let startDate = workout.startDate {
                        Text(formatDate(startDate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let duration = workoutDuration {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(duration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    private var workoutDuration: String? {
        guard let start = workout.startDate, let end = workout.endDate else { return nil }
        let duration = Int(end.timeIntervalSince(start))
        let mins = duration / 60
        return "\(mins) min"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Completed Workout Detail View

struct CompletedWorkoutDetailView: View {
    let workout: CompletedWorkout
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        if let start = workout.startDate {
                            Text(formatFullDate(start))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            if let duration = workoutDuration {
                                Label(duration, systemImage: "clock.fill")
                            }
                            Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Exercises
                    VStack(spacing: 12) {
                        ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, exercise in
                            CompletedExerciseRow(index: index + 1, exercise: exercise)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(workout.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var workoutDuration: String? {
        guard let start = workout.startDate, let end = workout.endDate else { return nil }
        let duration = Int(end.timeIntervalSince(start))
        let mins = duration / 60
        if mins >= 60 {
            let hours = mins / 60
            let remainingMins = mins % 60
            return "\(hours)h \(remainingMins)m"
        }
        return "\(mins) min"
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
        return formatter.string(from: date)
    }
}

struct CompletedExerciseRow: View {
    let index: Int
    let exercise: WorkoutExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(index).")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(exercise.exercise.name)
                    .font(.headline)
                
                Spacer()
            }
            
            // Sets summary
            Text(setsDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private var setsDescription: String {
        let setsCount = exercise.sets.count
        if let firstSet = exercise.sets.first {
            if firstSet.weight > 0 {
                return "\(setsCount) sets × \(firstSet.reps) reps @ \(Int(firstSet.weight))kg"
            } else if firstSet.timePerSet > 0 {
                return "\(setsCount) sets × \(firstSet.timePerSet)s"
            } else if firstSet.distance > 0 {
                return "\(firstSet.distance)m"
            }
            return "\(setsCount) sets × \(firstSet.reps) reps"
        }
        return "\(setsCount) sets"
    }
}

#Preview {
    WorkoutHistoryView()
}
