//
//  MindsetEntry.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation

/// Domain model for all mindset journal entry types
/// This is a unified value type that can represent any entry type
struct MindsetEntry: Identifiable, Equatable, Hashable {
    var id: String?
    var entryType: JournalEntryType

    // Common fields
    var title: String
    var content: String
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date

    // Daily bullet / Big goal outcomes
    var bulletPoints: [String]

    // Rewrite assumption fields
    var oldAssumptions: [String]
    var newAssumptions: [String]

    // Imaginal act fields
    var sceneDescription: String
    var reminderTime: Date?
    var notificationsEnabled: Bool

    // MARK: - Initializers

    /// Full initializer with all fields
    init(
        id: String? = nil,
        entryType: JournalEntryType,
        title: String = "",
        content: String = "",
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        bulletPoints: [String] = [],
        oldAssumptions: [String] = [],
        newAssumptions: [String] = [],
        sceneDescription: String = "",
        reminderTime: Date? = nil,
        notificationsEnabled: Bool = false
    ) {
        self.id = id
        self.entryType = entryType
        self.title = title
        self.content = content
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.bulletPoints = bulletPoints
        self.oldAssumptions = oldAssumptions
        self.newAssumptions = newAssumptions
        self.sceneDescription = sceneDescription
        self.reminderTime = reminderTime
        self.notificationsEnabled = notificationsEnabled
    }

    /// Creates a new regular journal entry
    static func regularJournal(title: String = "", content: String = "") -> MindsetEntry {
        MindsetEntry(
            entryType: .regularJournal,
            title: title,
            content: content
        )
    }

    /// Creates a new daily bullet journal entry
    static func dailyBullet(bulletPoints: [String] = [""]) -> MindsetEntry {
        MindsetEntry(
            entryType: .dailyBullet,
            bulletPoints: bulletPoints
        )
    }

    /// Creates a new big goal entry
    static func bigGoal(title: String = "", outcomes: [String] = [""]) -> MindsetEntry {
        MindsetEntry(
            entryType: .bigGoal,
            title: title,
            bulletPoints: outcomes
        )
    }

    /// Creates a new imaginal act entry
    static func imaginalAct(title: String = "", sceneDescription: String = "") -> MindsetEntry {
        MindsetEntry(
            entryType: .imaginalAct,
            title: title,
            sceneDescription: sceneDescription
        )
    }

    /// Creates a new rewrite assumption entry
    static func rewriteAssumption(title: String = "", oldAssumptions: [String] = [""], newAssumptions: [String] = [""]) -> MindsetEntry {
        MindsetEntry(
            entryType: .rewriteAssumption,
            title: title,
            oldAssumptions: oldAssumptions,
            newAssumptions: newAssumptions
        )
    }

    // MARK: - Computed Properties

    /// Preview text for list display
    var previewText: String {
        switch entryType {
        case .regularJournal:
            let preview = content.isEmpty ? "No content" : content
            return String(preview.prefix(100))
        case .dailyBullet:
            if bulletPoints.isEmpty || bulletPoints.allSatisfy({ $0.isEmpty }) {
                return "No bullet points"
            }
            return bulletPoints.filter { !$0.isEmpty }.prefix(3).map { "• \($0)" }.joined(separator: "\n")
        case .bigGoal:
            if bulletPoints.isEmpty || bulletPoints.allSatisfy({ $0.isEmpty }) {
                return "No outcomes defined"
            }
            return bulletPoints.filter { !$0.isEmpty }.prefix(2).map { "• \($0)" }.joined(separator: "\n")
        case .imaginalAct:
            return sceneDescription.isEmpty ? "No scene description" : String(sceneDescription.prefix(100))
        case .rewriteAssumption:
            if let old = oldAssumptions.first(where: { !$0.isEmpty }),
               let new = newAssumptions.first(where: { !$0.isEmpty }) {
                return "Old: \(old)\nNew: \(new)"
            }
            return "No assumptions defined"
        }
    }

    /// Display title for the entry
    var displayTitle: String {
        if !title.isEmpty {
            return title
        }
        switch entryType {
        case .regularJournal:
            return "Journal Entry"
        case .dailyBullet:
            return formattedDate
        case .bigGoal:
            return "Big Goal"
        case .imaginalAct:
            return "Imaginal Act"
        case .rewriteAssumption:
            return "Rewrite Assumption"
        }
    }

    /// Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }

    /// Formatted time string
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    /// Check if entry has meaningful content
    var hasContent: Bool {
        switch entryType {
        case .regularJournal:
            return !title.isEmpty || !content.isEmpty
        case .dailyBullet:
            return bulletPoints.contains { !$0.isEmpty }
        case .bigGoal:
            return !title.isEmpty || bulletPoints.contains { !$0.isEmpty }
        case .imaginalAct:
            return !title.isEmpty || !sceneDescription.isEmpty
        case .rewriteAssumption:
            return !title.isEmpty || oldAssumptions.contains { !$0.isEmpty } || newAssumptions.contains { !$0.isEmpty }
        }
    }
}

// MARK: - JSON Encoding for Arrays

extension MindsetEntry {
    /// Encode bullet points to JSON string
    func bulletPointsJSON() -> String? {
        guard let data = try? JSONEncoder().encode(bulletPoints) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Encode old assumptions to JSON string
    func oldAssumptionsJSON() -> String? {
        guard let data = try? JSONEncoder().encode(oldAssumptions) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Encode new assumptions to JSON string
    func newAssumptionsJSON() -> String? {
        guard let data = try? JSONEncoder().encode(newAssumptions) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Encode tags to JSON string
    func tagsJSON() -> String? {
        guard let data = try? JSONEncoder().encode(tags) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Decode string array from JSON
    static func decodeStringArray(from json: String?) -> [String] {
        guard let json, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
