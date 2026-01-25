//
//  FinanceSettings.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation

/// User settings for the Finance section
struct FinanceSettings: Equatable {
    var id: String?

    /// Base currency for display and calculations
    var baseCurrency: String

    /// How often to remind user to update manual values
    var updateReminderFrequency: UpdateReminderFrequency

    /// Whether update reminders are enabled
    var updateRemindersEnabled: Bool

    /// Last time user was reminded to update
    var lastReminderDate: Date?

    // MARK: - Initializers

    init(
        id: String? = nil,
        baseCurrency: String = "USD",
        updateReminderFrequency: UpdateReminderFrequency = .monthly,
        updateRemindersEnabled: Bool = false,
        lastReminderDate: Date? = nil
    ) {
        self.id = id
        self.baseCurrency = baseCurrency
        self.updateReminderFrequency = updateReminderFrequency
        self.updateRemindersEnabled = updateRemindersEnabled
        self.lastReminderDate = lastReminderDate
    }

    /// Default settings
    static let `default` = FinanceSettings()

    // MARK: - Computed Properties

    /// Whether a reminder is due
    var isReminderDue: Bool {
        guard updateRemindersEnabled else { return false }
        guard let lastReminder = lastReminderDate else { return true }

        let calendar = Calendar.current
        switch updateReminderFrequency {
        case .weekly:
            return calendar.dateComponents([.day], from: lastReminder, to: Date()).day ?? 0 >= 7
        case .monthly:
            return calendar.dateComponents([.month], from: lastReminder, to: Date()).month ?? 0 >= 1
        case .quarterly:
            return calendar.dateComponents([.month], from: lastReminder, to: Date()).month ?? 0 >= 3
        case .yearly:
            return calendar.dateComponents([.year], from: lastReminder, to: Date()).year ?? 0 >= 1
        }
    }
}

// MARK: - Update Reminder Frequency

enum UpdateReminderFrequency: String, CaseIterable, Codable, Identifiable {
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly: return "Yearly"
        }
    }

    var description: String {
        switch self {
        case .weekly: return "Remind every week"
        case .monthly: return "Remind every month"
        case .quarterly: return "Remind every 3 months"
        case .yearly: return "Remind once a year"
        }
    }
}
