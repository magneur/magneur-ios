//
//  FinanceStore.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation
import SwiftData
import Observation

/// Manages finance data persistence using SwiftData with CloudKit sync
@Observable
final class FinanceStore {

    static let shared = FinanceStore()

    private var modelContext: ModelContext?

    private init() {}

    /// Configure with the app's model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Financial Item Fetch Operations

    /// Fetch all items sorted by creation date (newest first)
    func fetchAllItems() -> [FinancialItem] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredFinancialItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toFinancialItem() }
        } catch {
            print("Failed to fetch financial items: \(error)")
            return []
        }
    }

    /// Fetch all assets
    func fetchAssets() -> [FinancialItem] {
        fetchAllItems().filter { $0.itemType.isAsset }
    }

    /// Fetch all liabilities
    func fetchLiabilities() -> [FinancialItem] {
        fetchAllItems().filter { $0.itemType.isLiability }
    }

    /// Fetch items of a specific type
    func fetchItems(ofType type: FinancialItemType) -> [FinancialItem] {
        guard let context = modelContext else { return [] }

        let typeRaw = type.rawValue
        let descriptor = FetchDescriptor<StoredFinancialItem>(
            predicate: #Predicate { $0.itemTypeRaw == typeRaw },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toFinancialItem() }
        } catch {
            print("Failed to fetch items of type \(type): \(error)")
            return []
        }
    }

    /// Fetch items that support live pricing
    func fetchLivePriceItems() -> [FinancialItem] {
        fetchAllItems().filter { $0.itemType.supportsLivePrice }
    }

    /// Fetch a single item by ID
    func fetchItem(byId id: String) -> FinancialItem? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<StoredFinancialItem>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let stored = try context.fetch(descriptor).first {
                return stored.toFinancialItem()
            }
        } catch {
            print("Failed to fetch item by ID: \(error)")
        }
        return nil
    }

    // MARK: - Financial Item Save Operations

    /// Save a new or update existing item
    func saveItem(_ item: FinancialItem) {
        guard let context = modelContext else { return }

        let id = item.id ?? UUID().uuidString

        var descriptor = FetchDescriptor<StoredFinancialItem>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.itemTypeRaw = item.itemType.rawValue
                existing.name = item.name
                existing.notes = item.notes
                existing.currency = item.currency
                existing.manualValueString = "\(item.manualValue)"
                existing.ticker = item.ticker
                existing.coinId = item.coinId
                existing.metalTypeRaw = item.metalType?.rawValue
                existing.quantityString = "\(item.quantity)"
                existing.lastFetchedPriceString = item.lastFetchedPrice.map { "\($0)" }
                existing.lastPriceUpdate = item.lastPriceUpdate
                existing.originalAmountString = item.originalAmount.map { "\($0)" }
                existing.interestRateString = item.interestRate.map { "\($0)" }
                existing.minimumPaymentString = item.minimumPayment.map { "\($0)" }
                existing.dueDay = item.dueDay
                existing.address = item.address
                existing.purchasePriceString = item.purchasePrice.map { "\($0)" }
                existing.purchaseDate = item.purchaseDate
                existing.accountType = item.accountType
                existing.institution = item.institution
                existing.updatedAt = Date()
            } else {
                // Create new
                var mutableItem = item
                mutableItem.id = id
                context.insert(mutableItem.toStoredFinancialItem())
            }

            try context.save()
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    /// Update item's live price
    func updateItemPrice(_ itemId: String, price: Decimal) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredFinancialItem>(
            predicate: #Predicate { $0.id == itemId }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                existing.lastFetchedPriceString = "\(price)"
                existing.lastPriceUpdate = Date()
                existing.updatedAt = Date()
                try context.save()
            }
        } catch {
            print("Failed to update item price: \(error)")
        }
    }

    // MARK: - Financial Item Delete Operations

    /// Delete an item
    func deleteItem(_ item: FinancialItem) {
        guard let context = modelContext, let id = item.id else { return }

        var descriptor = FetchDescriptor<StoredFinancialItem>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete item: \(error)")
        }
    }

    /// Delete item by ID
    func deleteItem(byId id: String) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredFinancialItem>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete item by ID: \(error)")
        }
    }

    // MARK: - Financial Goal Operations

    /// Fetch all goals sorted by target date
    func fetchAllGoals() -> [FinancialGoal] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredFinancialGoal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toFinancialGoal() }
        } catch {
            print("Failed to fetch goals: \(error)")
            return []
        }
    }

    /// Fetch goals of a specific type
    func fetchGoals(ofType type: GoalType) -> [FinancialGoal] {
        guard let context = modelContext else { return [] }

        let typeRaw = type.rawValue
        let descriptor = FetchDescriptor<StoredFinancialGoal>(
            predicate: #Predicate { $0.goalTypeRaw == typeRaw },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toFinancialGoal() }
        } catch {
            print("Failed to fetch goals of type \(type): \(error)")
            return []
        }
    }

    /// Fetch goal by ID
    func fetchGoal(byId id: String) -> FinancialGoal? {
        guard let context = modelContext else { return nil }

        var descriptor = FetchDescriptor<StoredFinancialGoal>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let stored = try context.fetch(descriptor).first {
                return stored.toFinancialGoal()
            }
        } catch {
            print("Failed to fetch goal by ID: \(error)")
        }
        return nil
    }

    /// Save a new or update existing goal
    func saveGoal(_ goal: FinancialGoal) {
        guard let context = modelContext else { return }

        let id = goal.id ?? UUID().uuidString

        var descriptor = FetchDescriptor<StoredFinancialGoal>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.name = goal.name
                existing.goalTypeRaw = goal.goalType.rawValue
                existing.targetAmountString = "\(goal.targetAmount)"
                existing.currentAmountString = "\(goal.currentAmount)"
                existing.currency = goal.currency
                existing.targetDate = goal.targetDate
                existing.notes = goal.notes
                existing.linkedItemId = goal.linkedItemId
                existing.updatedAt = Date()
            } else {
                // Create new
                var mutableGoal = goal
                mutableGoal.id = id
                context.insert(mutableGoal.toStoredFinancialGoal())
            }

            try context.save()
        } catch {
            print("Failed to save goal: \(error)")
        }
    }

    /// Update goal's current amount
    func updateGoalProgress(_ goalId: String, currentAmount: Decimal) {
        guard let context = modelContext else { return }

        var descriptor = FetchDescriptor<StoredFinancialGoal>(
            predicate: #Predicate { $0.id == goalId }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                existing.currentAmountString = "\(currentAmount)"
                existing.updatedAt = Date()
                try context.save()
            }
        } catch {
            print("Failed to update goal progress: \(error)")
        }
    }

    /// Delete a goal
    func deleteGoal(_ goal: FinancialGoal) {
        guard let context = modelContext, let id = goal.id else { return }

        var descriptor = FetchDescriptor<StoredFinancialGoal>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            print("Failed to delete goal: \(error)")
        }
    }

    // MARK: - Net Worth Snapshot Operations

    /// Fetch all snapshots sorted by date
    func fetchAllSnapshots() -> [NetWorthSnapshot] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredNetWorthSnapshot>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toNetWorthSnapshot() }
        } catch {
            print("Failed to fetch snapshots: \(error)")
            return []
        }
    }

    /// Fetch snapshots within a date range
    func fetchSnapshots(from startDate: Date, to endDate: Date) -> [NetWorthSnapshot] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<StoredNetWorthSnapshot>(
            predicate: #Predicate { $0.date >= startDate && $0.date <= endDate },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            let stored = try context.fetch(descriptor)
            return stored.map { $0.toNetWorthSnapshot() }
        } catch {
            print("Failed to fetch snapshots in range: \(error)")
            return []
        }
    }

    /// Check if snapshot exists for today
    func hasSnapshotForToday() -> Bool {
        guard let context = modelContext else { return false }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return false
        }

        let descriptor = FetchDescriptor<StoredNetWorthSnapshot>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )

        do {
            return try context.fetchCount(descriptor) > 0
        } catch {
            print("Failed to check for today's snapshot: \(error)")
            return false
        }
    }

    /// Save a snapshot
    func saveSnapshot(_ snapshot: NetWorthSnapshot) {
        guard let context = modelContext else { return }

        let id = snapshot.id ?? UUID().uuidString

        var descriptor = FetchDescriptor<StoredNetWorthSnapshot>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.date = snapshot.date
                existing.totalAssetsString = "\(snapshot.totalAssets)"
                existing.totalLiabilitiesString = "\(snapshot.totalLiabilities)"
                existing.currency = snapshot.currency
                existing.assetsByTypeJSON = snapshot.assetsByTypeJSON()
                existing.liabilitiesByTypeJSON = snapshot.liabilitiesByTypeJSON()
            } else {
                // Create new
                var mutableSnapshot = snapshot
                mutableSnapshot.id = id
                context.insert(mutableSnapshot.toStoredNetWorthSnapshot())
            }

            try context.save()
        } catch {
            print("Failed to save snapshot: \(error)")
        }
    }

    /// Create and save a snapshot from current items
    func createSnapshot(currency: String = "USD") {
        let items = fetchAllItems()
        let snapshot = NetWorthSnapshot.create(from: items, currency: currency)
        saveSnapshot(snapshot)
    }

    // MARK: - Settings Operations

    /// Fetch current settings
    func fetchSettings() -> FinanceSettings {
        guard let context = modelContext else { return .default }

        let settingsId = "settings"
        var descriptor = FetchDescriptor<StoredFinanceSettings>(
            predicate: #Predicate { $0.id == settingsId }
        )
        descriptor.fetchLimit = 1

        do {
            if let stored = try context.fetch(descriptor).first {
                return stored.toFinanceSettings()
            }
        } catch {
            print("Failed to fetch settings: \(error)")
        }
        return .default
    }

    /// Save settings
    func saveSettings(_ settings: FinanceSettings) {
        guard let context = modelContext else { return }

        let settingsId = settings.id ?? "settings"

        var descriptor = FetchDescriptor<StoredFinanceSettings>(
            predicate: #Predicate { $0.id == settingsId }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.baseCurrency = settings.baseCurrency
                existing.updateReminderFrequencyRaw = settings.updateReminderFrequency.rawValue
                existing.updateRemindersEnabled = settings.updateRemindersEnabled
                existing.lastReminderDate = settings.lastReminderDate
            } else {
                // Create new
                var mutableSettings = settings
                mutableSettings.id = settingsId
                context.insert(mutableSettings.toStoredFinanceSettings())
            }

            try context.save()
        } catch {
            print("Failed to save settings: \(error)")
        }
    }

    // MARK: - Net Worth Calculation

    /// Calculate current net worth
    func calculateNetWorth() -> (assets: Decimal, liabilities: Decimal, netWorth: Decimal) {
        let items = fetchAllItems()
        let assets = items.filter { $0.itemType.isAsset }.reduce(Decimal(0)) { $0 + $1.currentValue }
        let liabilities = items.filter { $0.itemType.isLiability }.reduce(Decimal(0)) { $0 + $1.currentValue }
        return (assets, liabilities, assets - liabilities)
    }

    /// Get item count by type
    func itemCount(forType type: FinancialItemType) -> Int {
        guard let context = modelContext else { return 0 }

        let typeRaw = type.rawValue
        let descriptor = FetchDescriptor<StoredFinancialItem>(
            predicate: #Predicate { $0.itemTypeRaw == typeRaw }
        )

        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("Failed to count items: \(error)")
            return 0
        }
    }

    /// Get total item count
    func totalItemCount() -> Int {
        guard let context = modelContext else { return 0 }

        let descriptor = FetchDescriptor<StoredFinancialItem>()

        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("Failed to count total items: \(error)")
            return 0
        }
    }

    /// Get total goal count
    func totalGoalCount() -> Int {
        guard let context = modelContext else { return 0 }

        let descriptor = FetchDescriptor<StoredFinancialGoal>()

        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("Failed to count total goals: \(error)")
            return 0
        }
    }
}
