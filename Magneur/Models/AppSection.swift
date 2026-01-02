//
//  AppSection.swift
//  Magneur
//
//  Created by Andrew on 02.01.2026.
//

import SwiftUI

/// Represents the five main sections of the app.
enum AppSection: String, CaseIterable, Identifiable {
    case fitness = "Fitness"
    case finance = "Finance"
    case todo = "To-Do"
    case journal = "Journal"
    case travel = "Travel"
    
    var id: String { rawValue }
    
    /// SF Symbol icon for the section.
    var icon: String {
        switch self {
        case .fitness: return "figure.run"
        case .finance: return "dollarsign.circle"
        case .todo: return "checklist"
        case .journal: return "book"
        case .travel: return "airplane"
        }
    }
    
    /// Gradient colors for section backgrounds.
    var gradientColors: [Color] {
        switch self {
        case .fitness: return [Color.orange, Color.red]
        case .finance: return [Color.green, Color.mint]
        case .todo: return [Color.blue, Color.indigo]
        case .journal: return [Color.purple, Color.pink]
        case .travel: return [Color.cyan, Color.teal]
        }
    }
}
