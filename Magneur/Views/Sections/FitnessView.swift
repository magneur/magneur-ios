//
//  FitnessView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Placeholder view for the Fitness section.
struct FitnessView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: AppSection.fitness.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: AppSection.fitness.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("Fitness")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Your workout dashboard")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    FitnessView()
}
