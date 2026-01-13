//
//  WorkoutCreationView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Multi-step workout creation/editing flow
struct WorkoutCreationView: View {
    var existingWorkout: Workout?
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var exercises: [WorkoutExercise] = []
    @State private var selectedColor: String = "#FF5722FF"
    @State private var selectedIcon: String = "lifting"
    @State private var startDate: Date?
    @State private var hasRecurrence: Bool = false
    
    @State private var currentStep: CreationStep = .nameDescription
    @State private var showingExercisePicker = false
    @State private var editingExerciseIndex: Int?
    
    @Environment(\.dismiss) private var dismiss
    
    enum CreationStep: Int, CaseIterable {
        case nameDescription
        case exercises
        case style
        case schedule
        
        var title: String {
            switch self {
            case .nameDescription: return "Details"
            case .exercises: return "Exercises"
            case .style: return "Style"
            case .schedule: return "Schedule"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator
                    
                    // Content
                    TabView(selection: $currentStep) {
                        nameDescriptionStep
                            .tag(CreationStep.nameDescription)
                        
                        exercisesStep
                            .tag(CreationStep.exercises)
                        
                        styleStep
                            .tag(CreationStep.style)
                        
                        scheduleStep
                            .tag(CreationStep.schedule)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Navigation buttons
                    navigationButtons
                }
            }
            .navigationTitle(existingWorkout != nil ? "Edit Workout" : "New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { exercise in
                    let workoutExercise = WorkoutExercise(
                        exercise: exercise,
                        sets: [ExerciseSet(id: UUID().uuidString, reps: 10, weight: 0, rest: 90, timePerSet: 0, distance: 0)]
                    )
                    exercises.append(workoutExercise)
                }
            }
            .sheet(item: $editingExerciseIndex) { index in
                if index < exercises.count {
                    ExerciseEditorView(workoutExercise: $exercises[index])
                }
            }
        }
        .onAppear {
            if let workout = existingWorkout {
                name = workout.name
                description = workout.workoutDescription ?? ""
                exercises = workout.exercises
                selectedColor = workout.color ?? "#FF5722FF"
                selectedIcon = workout.iconName ?? "lifting"
                startDate = workout.startDate
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(CreationStep.allCases, id: \.self) { step in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(step.rawValue <= currentStep.rawValue ? Color.orange : Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Text(step.title)
                        .font(.caption2)
                        .foregroundStyle(step == currentStep ? .primary : .secondary)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Step Views
    
    private var nameDescriptionStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Name")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Morning Strength", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (optional)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("What's this workout about?", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
            }
            .padding()
        }
    }
    
    private var exercisesStep: some View {
        VStack(spacing: 0) {
            if exercises.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    
                    Text("No exercises yet")
                        .font(.headline)
                    
                    Text("Add exercises to build your workout")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(exercises.enumerated()), id: \.element.exercise.id) { index, exercise in
                        ExerciseListRow(exercise: exercise)
                            .onTapGesture {
                                editingExerciseIndex = index
                            }
                    }
                    .onDelete { indexSet in
                        exercises.remove(atOffsets: indexSet)
                    }
                    .onMove { source, destination in
                        exercises.move(fromOffsets: source, toOffset: destination)
                    }
                }
                .listStyle(.insetGrouped)
            }
            
            Button {
                showingExercisePicker = true
            } label: {
                Label("Add Exercise", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.orange)
                    )
            }
            .padding()
        }
    }
    
    private var styleStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Color picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .orange)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2)
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                // Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preview")
                        .font(.headline)
                    
                    HStack {
                        Spacer()
                        WorkoutCardView(workout: Workout(
                            id: "preview",
                            name: name.isEmpty ? "Workout Name" : name,
                            exercises: exercises,
                            color: selectedColor,
                            iconName: selectedIcon
                        ))
                        .frame(width: 150)
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
    
    private var scheduleStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Toggle("Schedule this workout", isOn: Binding(
                    get: { startDate != nil },
                    set: { if $0 { startDate = Date() } else { startDate = nil } }
                ))
                
                if startDate != nil {
                    DatePicker(
                        "Start Date",
                        selection: Binding(get: { startDate ?? Date() }, set: { startDate = $0 }),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    Toggle("Repeat", isOn: $hasRecurrence)
                    
                    if hasRecurrence {
                        Text("Weekly recurrence will be added")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Navigation
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep != .nameDescription {
                Button {
                    withAnimation {
                        currentStep = CreationStep(rawValue: currentStep.rawValue - 1) ?? .nameDescription
                    }
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
            }
            
            Button {
                if currentStep == .schedule {
                    saveWorkout()
                } else {
                    withAnimation {
                        currentStep = CreationStep(rawValue: currentStep.rawValue + 1) ?? .schedule
                    }
                }
            } label: {
                Text(currentStep == .schedule ? "Save Workout" : "Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(canProceed ? .orange : .gray)
                    )
            }
            .disabled(!canProceed)
        }
        .padding()
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .nameDescription:
            return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .exercises:
            return !exercises.isEmpty
        case .style, .schedule:
            return true
        }
    }
    
    private func saveWorkout() {
        var workout = Workout(
            id: existingWorkout?.id ?? UUID().uuidString,
            name: name,
            workoutDescription: description.isEmpty ? nil : description,
            startDate: startDate,
            exercises: exercises,
            recurrenceString: hasRecurrence ? "FREQ=WEEKLY" : nil,
            color: selectedColor,
            iconName: selectedIcon
        )
        
        WorkoutStore.shared.saveWorkout(workout)
        dismiss()
    }
    
    private var colorOptions: [String] {
        [
            "#FF5722FF", "#E91E63FF", "#9C27B0FF", "#673AB7FF",
            "#3F51B5FF", "#2196F3FF", "#03A9F4FF", "#00BCD4FF",
            "#009688FF", "#4CAF50FF", "#8BC34AFF", "#CDDC39FF",
            "#FFC107FF", "#FF9800FF", "#795548FF", "#607D8BFF"
        ]
    }
}

// MARK: - Exercise List Row

struct ExerciseListRow: View {
    let exercise: WorkoutExercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exercise.name)
                    .font(.headline)
                
                Text("\(exercise.sets.count) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Int Extension for Binding

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    WorkoutCreationView()
}
