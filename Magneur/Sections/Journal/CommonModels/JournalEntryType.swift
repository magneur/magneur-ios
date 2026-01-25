//
//  JournalEntryType.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Represents the different types of journal entries in the mindset journal
enum JournalEntryType: String, CaseIterable, Codable, Identifiable {
    case regularJournal = "journal"
    case dailyBullet = "dailyBullet"
    case bigGoal = "bigGoal"
    case imaginalAct = "imaginalAct"
    case rewriteAssumption = "rewriteAssumption"

    var id: String { rawValue }

    /// Display name for the entry type
    var displayName: String {
        switch self {
        case .regularJournal: return "Journal"
        case .dailyBullet: return "Daily Bullets"
        case .bigGoal: return "Big Goal"
        case .imaginalAct: return "Imaginal Act"
        case .rewriteAssumption: return "Rewrite Assumption"
        }
    }

    /// Short display name for filter chips
    var shortName: String {
        switch self {
        case .regularJournal: return "Journal"
        case .dailyBullet: return "Bullets"
        case .bigGoal: return "Goal"
        case .imaginalAct: return "Imaginal"
        case .rewriteAssumption: return "Rewrite"
        }
    }

    /// SF Symbol icon for the entry type
    var icon: String {
        switch self {
        case .regularJournal: return "book.fill"
        case .dailyBullet: return "list.bullet"
        case .bigGoal: return "star.fill"
        case .imaginalAct: return "moon.stars.fill"
        case .rewriteAssumption: return "arrow.triangle.2.circlepath"
        }
    }

    /// Accent color for the entry type
    var accentColor: Color {
        switch self {
        case .regularJournal: return .purple
        case .dailyBullet: return .blue
        case .bigGoal: return .orange
        case .imaginalAct: return .indigo
        case .rewriteAssumption: return .green
        }
    }

    /// Description for entry type selection
    var description: String {
        switch self {
        case .regularJournal:
            return "Free-form journaling for your thoughts and reflections"
        case .dailyBullet:
            return "Daily reflections with bullet points"
        case .bigGoal:
            return "Define your long-term goals and desired outcomes"
        case .imaginalAct:
            return "Visualization scenes for bedtime practice"
        case .rewriteAssumption:
            return "Transform limiting beliefs into empowering ones"
        }
    }
}
