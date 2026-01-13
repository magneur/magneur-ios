//
//  WorkoutListView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Main workout list showing custom workouts and templates
struct WorkoutListView: View {
    @Binding var showingCreateWorkout: Bool
    
    @State private var customWorkouts: [Workout] = []
    @State private var selectedWorkout: Workout?
    @State private var showHistory = false
    @State private var workoutToDelete: Workout?
    @State private var showDeleteConfirmation = false
    
    private let templates = WorkoutTemplateStore.shared.workoutTemplates
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with history button
                HStack {
                    Spacer()
                    Button {
                        showHistory = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("History")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial.opacity(0.3))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                
                // Custom Workouts Section with delete support
                if !customWorkouts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        // Section Header
                        Text("Your Workouts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        // Workout Grid with context menu
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(customWorkouts) { workout in
                                WorkoutCardView(workout: workout)
                                    .onTapGesture {
                                        selectedWorkout = workout
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            workoutToDelete = workout
                                            showDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Template Sections
                ForEach(WorkoutTemplateType.allCases) { type in
                    if let workouts = templates[type], !workouts.isEmpty {
                        WorkoutSection(
                            title: type.rawValue,
                            icon: type.icon,
                            workouts: workouts,
                            onSelect: { workout in
                                selectedWorkout = workout
                            }
                        )
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadCustomWorkouts()
        }
        .navigationDestination(item: $selectedWorkout) { workout in
            WorkoutDetailView(workout: workout)
        }
        .sheet(isPresented: $showHistory) {
            WorkoutHistoryView()
        }
        .alert("Delete Workout?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                workoutToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let workout = workoutToDelete {
                    deleteWorkout(workout)
                }
            }
        } message: {
            Text("This will permanently delete \"\(workoutToDelete?.name ?? "")\" and cannot be undone.")
        }
    }
    
    private func loadCustomWorkouts() {
        customWorkouts = WorkoutStore.shared.fetchWorkouts()
    }
    
    private func deleteWorkout(_ workout: Workout) {
        WorkoutStore.shared.deleteWorkout(workout)
        withAnimation {
            customWorkouts.removeAll { $0.id == workout.id }
        }
        workoutToDelete = nil
    }
}

// MARK: - Workout Section

struct WorkoutSection: View {
    let title: String
    var icon: String? = nil
    let workouts: [Workout]
    let onSelect: (Workout) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal)
            
            // Workout Grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(workouts) { workout in
                    WorkoutCardView(workout: workout)
                        .onTapGesture {
                            onSelect(workout)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.orange.ignoresSafeArea()
            WorkoutListView(showingCreateWorkout: .constant(false))
        }
    }
}
