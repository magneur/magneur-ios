//
//  ExercisePickerView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Searchable picker for selecting exercises from the catalog
struct ExercisePickerView: View {
    let onSelect: (Exercise) -> Void
    
    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory?
    @State private var showingCustomExercise = false
    @Environment(\.dismiss) private var dismiss
    
    private var filteredExercises: [Exercise] {
        var exercises = allExercises
        
        if let category = selectedCategory {
            exercises = exercises.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            exercises = exercises.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return exercises
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue.capitalized,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                
                // Exercise list
                List {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRow(exercise: exercise)
                            .onTapGesture {
                                onSelect(exercise)
                                dismiss()
                            }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCustomExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCustomExercise) {
                CustomExerciseView { exercise in
                    onSelect(exercise)
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? .orange : Color(.secondarySystemGroupedBackground))
                )
        }
    }
}

// MARK: - Exercise Row

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            categoryIcon
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.headline)
                
                Text(exercise.category.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Execution type indicator
            executionTypeLabel
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var categoryIcon: some View {
        switch exercise.category {
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
        case .sport:
            Image(systemName: "figure.run")
        case .duration, .other:
            Image(systemName: "figure.mixed.cardio")
        }
    }
    
    @ViewBuilder
    private var executionTypeLabel: some View {
        switch exercise.executionType {
        case .setsReps:
            Label("Reps", systemImage: "repeat")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .timedSets, .timedExercise:
            Label("Timed", systemImage: "timer")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .distance:
            Label("Distance", systemImage: "location")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .open:
            Label("Open", systemImage: "infinity")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Custom Exercise View

struct CustomExerciseView: View {
    let onCreate: (Exercise) -> Void
    
    @State private var name = ""
    @State private var category: ExerciseCategory = .bodyweight
    @State private var executionType: ExecutionType = .setsReps
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Name") {
                    TextField("e.g., Custom Push-up", text: $name)
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue.capitalized).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Type") {
                    Picker("Type", selection: $executionType) {
                        Text("Sets & Reps").tag(ExecutionType.setsReps)
                        Text("Timed Sets").tag(ExecutionType.timedSets)
                        Text("Distance").tag(ExecutionType.distance)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let exercise = Exercise(
                            id: UUID().uuidString,
                            name: name,
                            description: "",
                            sportCategory: .fitness,
                            sport: 0,
                            category: category,
                            executionType: executionType,
                            isCustom: true
                        )
                        onCreate(exercise)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Exercise Catalog

private var allExercises: [Exercise] {
    ExerciseCatalog.allExercises
}

#Preview {
    ExercisePickerView { exercise in
        print("Selected: \(exercise.name)")
    }
}
