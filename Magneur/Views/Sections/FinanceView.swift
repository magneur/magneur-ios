//
//  FinanceView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Placeholder view for the Finance section.
struct FinanceView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: AppSection.finance.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: AppSection.finance.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("Finance")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Your financial overview")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    FinanceView()
}
