//
//  JournalModels.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation
import SwiftData

/// SwiftData model for mindset journal entries
/// Named StoredMindsetEntry to avoid conflict with Travel's StoredJournalEntry
@Model
final class StoredMindsetEntry {
    @Attribute(.unique) var id: String
    var entryTypeRaw: String

    // Common fields
    var title: String
    var content: String
    var tagsJSON: String?
    var createdAt: Date
    var updatedAt: Date

    // Bullet points / outcomes (stored as JSON)
    var bulletPointsJSON: String?

    // Rewrite assumption fields (stored as JSON)
    var oldAssumptionsJSON: String?
    var newAssumptionsJSON: String?

    // Imaginal act fields
    var sceneDescription: String?
    var reminderTime: Date?
    var notificationsEnabled: Bool

    init(
        id: String = UUID().uuidString,
        entryType: JournalEntryType,
        title: String = "",
        content: String = "",
        tagsJSON: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        bulletPointsJSON: String? = nil,
        oldAssumptionsJSON: String? = nil,
        newAssumptionsJSON: String? = nil,
        sceneDescription: String? = nil,
        reminderTime: Date? = nil,
        notificationsEnabled: Bool = false
    ) {
        self.id = id
        self.entryTypeRaw = entryType.rawValue
        self.title = title
        self.content = content
        self.tagsJSON = tagsJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.bulletPointsJSON = bulletPointsJSON
        self.oldAssumptionsJSON = oldAssumptionsJSON
        self.newAssumptionsJSON = newAssumptionsJSON
        self.sceneDescription = sceneDescription
        self.reminderTime = reminderTime
        self.notificationsEnabled = notificationsEnabled
    }

    /// Convert to domain model
    func toMindsetEntry() -> MindsetEntry {
        MindsetEntry(stored: self)
    }

    /// Entry type computed property
    var entryType: JournalEntryType {
        JournalEntryType(rawValue: entryTypeRaw) ?? .regularJournal
    }
}

// MARK: - Domain Model Extension

extension MindsetEntry {
    /// Initialize from stored model
    init(stored: StoredMindsetEntry) {
        self.id = stored.id
        self.entryType = stored.entryType
        self.title = stored.title
        self.content = stored.content
        self.tags = Self.decodeStringArray(from: stored.tagsJSON)
        self.createdAt = stored.createdAt
        self.updatedAt = stored.updatedAt
        self.bulletPoints = Self.decodeStringArray(from: stored.bulletPointsJSON)
        self.oldAssumptions = Self.decodeStringArray(from: stored.oldAssumptionsJSON)
        self.newAssumptions = Self.decodeStringArray(from: stored.newAssumptionsJSON)
        self.sceneDescription = stored.sceneDescription ?? ""
        self.reminderTime = stored.reminderTime
        self.notificationsEnabled = stored.notificationsEnabled
    }

    /// Convert to stored model
    func toStoredMindsetEntry() -> StoredMindsetEntry {
        StoredMindsetEntry(
            id: id ?? UUID().uuidString,
            entryType: entryType,
            title: title,
            content: content,
            tagsJSON: tagsJSON(),
            createdAt: createdAt,
            updatedAt: updatedAt,
            bulletPointsJSON: bulletPointsJSON(),
            oldAssumptionsJSON: oldAssumptionsJSON(),
            newAssumptionsJSON: newAssumptionsJSON(),
            sceneDescription: sceneDescription,
            reminderTime: reminderTime,
            notificationsEnabled: notificationsEnabled
        )
    }
}
