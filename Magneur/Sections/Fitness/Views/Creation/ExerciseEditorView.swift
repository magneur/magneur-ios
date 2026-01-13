//
//  ExerciseEditorView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Editor for configuring sets within a workout exercise
struct ExerciseEditorView: View {
    @Binding var workoutExercise: WorkoutExercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Exercise info
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workoutExercise.exercise.name)
                            .font(.headline)
                        Text(workoutExercise.exercise.category.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Sets
                Section("Sets") {
                    ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                        SetEditorRow(
                            setNumber: index + 1,
                            set: binding(for: index),
                            executionType: workoutExercise.exercise.executionType
                        )
                    }
                    .onDelete { indexSet in
                        workoutExercise.sets.remove(atOffsets: indexSet)
                    }
                    
                    Button {
                        addSet()
                    } label: {
                        Label("Add Set", systemImage: "plus.circle.fill")
                    }
                }
                
                // Rest time (applies to all sets)
                Section("Rest Between Sets") {
                    Picker("Rest Time", selection: Binding(
                        get: { workoutExercise.sets.first?.rest ?? 90 },
                        set: { newValue in
                            for i in 0..<workoutExercise.sets.count {
                                workoutExercise.sets[i].rest = newValue
                            }
                        }
                    )) {
                        Text("30s").tag(30)
                        Text("60s").tag(60)
                        Text("90s").tag(90)
                        Text("2 min").tag(120)
                        Text("3 min").tag(180)
                        Text("5 min").tag(300)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func binding(for index: Int) -> Binding<ExerciseSet> {
        Binding(
            get: { workoutExercise.sets[index] },
            set: { workoutExercise.sets[index] = $0 }
        )
    }
    
    private func addSet() {
        let lastSet = workoutExercise.sets.last
        let newSet = ExerciseSet(
            id: UUID().uuidString,
            reps: lastSet?.reps ?? 10,
            weight: lastSet?.weight ?? 0,
            rest: lastSet?.rest ?? 90,
            timePerSet: lastSet?.timePerSet ?? 60,
            distance: lastSet?.distance ?? 0
        )
        workoutExercise.sets.append(newSet)
    }
}

// MARK: - Set Editor Row

struct SetEditorRow: View {
    let setNumber: Int
    @Binding var set: ExerciseSet
    let executionType: ExecutionType
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Set \(setNumber)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            switch executionType {
            case .setsReps:
                setsRepsEditor
            case .timedSets, .timedExercise:
                timedEditor
            case .distance:
                distanceEditor
            case .open:
                Text("Complete when ready")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var setsRepsEditor: some View {
        HStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Reps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Stepper(value: $set.reps, in: 1...100) {
                    Text("\(set.reps)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
            }
            
            VStack(spacing: 4) {
                Text("Weight (kg)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Button {
                        set.weight = max(0, set.weight - 2.5)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                    }
                    
                    Text(String(format: "%.1f", set.weight))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .frame(minWidth: 60)
                    
                    Button {
                        set.weight += 2.5
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .foregroundStyle(.orange)
            }
        }
    }
    
    private var timedEditor: some View {
        VStack(spacing: 4) {
            Text("Duration")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Button {
                    set.timePerSet = max(5, set.timePerSet - 5)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }
                
                Text(formatTime(set.timePerSet))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .frame(minWidth: 80)
                
                Button {
                    set.timePerSet += 5
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .foregroundStyle(.orange)
        }
    }
    
    private var distanceEditor: some View {
        VStack(spacing: 4) {
            Text("Distance")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Button {
                    set.distance = max(0, set.distance - 100)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }
                
                Text(formatDistance(set.distance))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .frame(minWidth: 80)
                
                Button {
                    set.distance += 100
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .foregroundStyle(.orange)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return secs > 0 ? "\(mins)m \(secs)s" : "\(mins) min"
        }
        return "\(secs)s"
    }
    
    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", Double(meters) / 1000.0)
        }
        return "\(meters)m"
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var exercise = WorkoutExercise(
            exercise: Exercise(id: "test", name: "Bench Press", description: "", sportCategory: .weightlifting, sport: 0, category: .barbell, executionType: .setsReps),
            sets: [
                ExerciseSet(id: "1", reps: 5, weight: 60, rest: 90, timePerSet: 0, distance: 0),
                ExerciseSet(id: "2", reps: 5, weight: 60, rest: 90, timePerSet: 0, distance: 0),
            ]
        )
        
        var body: some View {
            ExerciseEditorView(workoutExercise: $exercise)
        }
    }
    
    return PreviewWrapper()
}
