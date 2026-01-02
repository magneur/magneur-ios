//
//  ToDoView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Placeholder view for the To-Do section.
struct ToDoView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: AppSection.todo.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: AppSection.todo.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("To-Do")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Your task manager")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    ToDoView()
}
