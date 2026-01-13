//
//  SectionContentView.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Switcher view that displays the appropriate section content.
struct SectionContentView: View {
    let section: AppSection
    
    var body: some View {
        switch section {
        case .fitness:
            FitnessView()
        case .finance:
            FinanceView()
        case .todo:
            ToDoView()
        case .journal:
            JournalView()
        case .travel:
            TravelView()
        }
    }
}

#Preview {
    SectionContentView(section: .fitness)
}
