//
//  FitnessView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI
import SwiftData

/// Main fitness section with tab-based navigation
struct FitnessView: View {
    @State private var selectedTab: FitnessTab = .workouts
    @State private var showingCreateWorkout = false
    
    enum FitnessTab: String, CaseIterable {
        case workouts = "Workouts"
        case calendar = "Calendar"
        
        var icon: String {
            switch self {
            case .workouts: return "dumbbell.fill"
            case .calendar: return "calendar"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: AppSection.fitness.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom tab bar
                    HStack(spacing: 0) {
                        ForEach(FitnessTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 20))
                                    Text(tab.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .background(.ultraThinMaterial.opacity(0.3))
                    
                    // Tab content
                    TabView(selection: $selectedTab) {
                        WorkoutListView(showingCreateWorkout: $showingCreateWorkout)
                            .tag(FitnessTab.workouts)
                        
                        FitnessCalendarView()
                            .tag(FitnessTab.calendar)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Fitness")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedTab == .workouts {
                        Button {
                            showingCreateWorkout = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingCreateWorkout) {
            WorkoutCreationView()
        }
    }
}

#Preview {
    FitnessView()
        .modelContainer(for: [StoredWorkout.self, StoredCompletedWorkout.self], inMemory: true)
}

