//
//  WorkoutCompletionView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Post-workout summary view
struct WorkoutCompletionView: View {
    let workout: Workout
    let duration: Int
    let onSave: () -> Void
    let onDiscard: () -> Void
    
    @State private var showingConfetti = true
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
            }
            .scaleEffect(showingConfetti ? 1.0 : 0.5)
            .opacity(showingConfetti ? 1.0 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showingConfetti)
            
            // Congratulations text
            VStack(spacing: 8) {
                Text("Workout Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Great job finishing \(workout.name)")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            // Stats
            HStack(spacing: 40) {
                StatItem(
                    icon: "clock.fill",
                    value: formatDuration(duration),
                    label: "Duration"
                )
                
                StatItem(
                    icon: "flame.fill",
                    value: "\(workout.exercises.count)",
                    label: "Exercises"
                )
                
                StatItem(
                    icon: "repeat",
                    value: "\(totalSets)",
                    label: "Sets"
                )
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial.opacity(0.4))
            )
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                Button {
                    onSave()
                } label: {
                    Text("Save Workout")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.green)
                        )
                }
                
                Button {
                    onDiscard()
                } label: {
                    Text("Discard")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .onAppear {
            // Trigger animation
            showingConfetti = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingConfetti = true
            }
        }
    }
    
    private var totalSets: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins >= 60 {
            let hours = mins / 60
            let remainingMins = mins % 60
            return "\(hours)h \(remainingMins)m"
        }
        return "\(mins):\(String(format: "%02d", secs))"
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white.opacity(0.7))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.8).ignoresSafeArea()
        
        WorkoutCompletionView(
            workout: WorkoutTemplateStore.shared.allTemplates.first!,
            duration: 1847,
            onSave: {},
            onDiscard: {}
        )
    }
}
