//
//  WorkoutCardView.swift
//  Magneur
//
//  Created by Claude on 13.01.2026.
//

import SwiftUI

/// Card view for displaying a workout in the grid
struct WorkoutCardView: View {
    let workout: Workout
    
    private var gradientColors: [Color] {
        if let colorHex = workout.color {
            let color = Color(hex: colorHex) ?? .orange
            return [color, color.opacity(0.7)]
        }
        return [.orange, .red]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                workoutIcon
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
            
            // Name
            Text(workout.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            // Exercise count
            Text("\(workout.exercises.count) exercises")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
    
    @ViewBuilder
    private var workoutIcon: some View {
        if let iconName = workout.iconName {
            // Try system image first, then fallback
            switch iconName {
            case "bench-press", "weightlifting", "lifting":
                Image(systemName: "dumbbell.fill")
            case "squat", "lunge":
                Image(systemName: "figure.strengthtraining.traditional")
            case "run":
                Image(systemName: "figure.run")
            case "yoga":
                Image(systemName: "figure.mind.and.body")
            default:
                Image(systemName: "figure.strengthtraining.functional")
            }
        } else {
            Image(systemName: "figure.strengthtraining.functional")
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        var alpha: Double = 1.0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        switch hexSanitized.count {
        case 6:
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        case 8:
            alpha = Double(rgb & 0x000000FF) / 255.0
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: alpha
            )
        default:
            return nil
        }
    }
}

#Preview {
    let workout = Workout(
        id: "test",
        name: "Push Workout",
        workoutDescription: "Chest and triceps",
        exercises: [],
        color: "#9B1C1CFF",
        iconName: "bench-press"
    )
    
    WorkoutCardView(workout: workout)
        .frame(width: 160)
        .padding()
        .background(Color.gray.opacity(0.3))
}
