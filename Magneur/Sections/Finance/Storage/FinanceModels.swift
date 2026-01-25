//
//  FinanceModels.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation
import SwiftData

// MARK: - Stored Financial Item

/// SwiftData model for financial items
@Model
final class StoredFinancialItem {
    @Attribute(.unique) var id: String
    var itemTypeRaw: String
    var name: String
    var notes: String
    var currency: String
    var createdAt: Date
    var updatedAt: Date

    // Value (stored as String for CloudKit compatibility)
    var manualValueString: String

    // Live price fields
    var ticker: String?
    var coinId: String?
    var metalTypeRaw: String?
    var quantityString: String
    var lastFetchedPriceString: String?
    var lastPriceUpdate: Date?

    // Liability fields
    var originalAmountString: String?
    var interestRateString: String?
    var minimumPaymentString: String?
    var dueDay: Int?

    // Real estate fields
    var address: String?
    var purchasePriceString: String?
    var purchaseDate: Date?

    // Account fields
    var accountType: String?
    var institution: String?

    init(
        id: String = UUID().uuidString,
        itemType: FinancialItemType,
        name: String = "",
        notes: String = "",
        currency: String = "USD",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        manualValue: Decimal = 0,
        ticker: String? = nil,
        coinId: String? = nil,
        metalType: MetalType? = nil,
        quantity: Decimal = 0,
        lastFetchedPrice: Decimal? = nil,
        lastPriceUpdate: Date? = nil,
        originalAmount: Decimal? = nil,
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil,
        address: String? = nil,
        purchasePrice: Decimal? = nil,
        purchaseDate: Date? = nil,
        accountType: String? = nil,
        institution: String? = nil
    ) {
        self.id = id
        self.itemTypeRaw = itemType.rawValue
        self.name = name
        self.notes = notes
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.manualValueString = "\(manualValue)"
        self.ticker = ticker
        self.coinId = coinId
        self.metalTypeRaw = metalType?.rawValue
        self.quantityString = "\(quantity)"
        self.lastFetchedPriceString = lastFetchedPrice.map { "\($0)" }
        self.lastPriceUpdate = lastPriceUpdate
        self.originalAmountString = originalAmount.map { "\($0)" }
        self.interestRateString = interestRate.map { "\($0)" }
        self.minimumPaymentString = minimumPayment.map { "\($0)" }
        self.dueDay = dueDay
        self.address = address
        self.purchasePriceString = purchasePrice.map { "\($0)" }
        self.purchaseDate = purchaseDate
        self.accountType = accountType
        self.institution = institution
    }

    /// Convert to domain model
    func toFinancialItem() -> FinancialItem {
        FinancialItem(stored: self)
    }

    /// Item type computed property
    var itemType: FinancialItemType {
        FinancialItemType(rawValue: itemTypeRaw) ?? .otherAsset
    }

    /// Metal type computed property
    var metalType: MetalType? {
        guard let raw = metalTypeRaw else { return nil }
        return MetalType(rawValue: raw)
    }
}

// MARK: - Domain Model Extension

extension FinancialItem {
    /// Initialize from stored model
    init(stored: StoredFinancialItem) {
        self.id = stored.id
        self.itemType = stored.itemType
        self.name = stored.name
        self.notes = stored.notes
        self.currency = stored.currency
        self.createdAt = stored.createdAt
        self.updatedAt = stored.updatedAt
        self.manualValue = Decimal(string: stored.manualValueString) ?? 0
        self.ticker = stored.ticker
        self.coinId = stored.coinId
        self.metalType = stored.metalType
        self.quantity = Decimal(string: stored.quantityString) ?? 0
        self.lastFetchedPrice = stored.lastFetchedPriceString.flatMap { Decimal(string: $0) }
        self.lastPriceUpdate = stored.lastPriceUpdate
        self.originalAmount = stored.originalAmountString.flatMap { Decimal(string: $0) }
        self.interestRate = stored.interestRateString.flatMap { Decimal(string: $0) }
        self.minimumPayment = stored.minimumPaymentString.flatMap { Decimal(string: $0) }
        self.dueDay = stored.dueDay
        self.address = stored.address
        self.purchasePrice = stored.purchasePriceString.flatMap { Decimal(string: $0) }
        self.purchaseDate = stored.purchaseDate
        self.accountType = stored.accountType
        self.institution = stored.institution
    }

    /// Convert to stored model
    func toStoredFinancialItem() -> StoredFinancialItem {
        StoredFinancialItem(
            id: id ?? UUID().uuidString,
            itemType: itemType,
            name: name,
            notes: notes,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            manualValue: manualValue,
            ticker: ticker,
            coinId: coinId,
            metalType: metalType,
            quantity: quantity,
            lastFetchedPrice: lastFetchedPrice,
            lastPriceUpdate: lastPriceUpdate,
            originalAmount: originalAmount,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay,
            address: address,
            purchasePrice: purchasePrice,
            purchaseDate: purchaseDate,
            accountType: accountType,
            institution: institution
        )
    }
}

// MARK: - Stored Financial Goal

/// SwiftData model for financial goals
@Model
final class StoredFinancialGoal {
    @Attribute(.unique) var id: String
    var name: String
    var goalTypeRaw: String
    var targetAmountString: String
    var currentAmountString: String
    var currency: String
    var targetDate: Date?
    var createdAt: Date
    var updatedAt: Date
    var notes: String
    var linkedItemId: String?

    init(
        id: String = UUID().uuidString,
        name: String = "",
        goalType: GoalType = .savingsTarget,
        targetAmount: Decimal = 0,
        currentAmount: Decimal = 0,
        currency: String = "USD",
        targetDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String = "",
        linkedItemId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.goalTypeRaw = goalType.rawValue
        self.targetAmountString = "\(targetAmount)"
        self.currentAmountString = "\(currentAmount)"
        self.currency = currency
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.linkedItemId = linkedItemId
    }

    /// Convert to domain model
    func toFinancialGoal() -> FinancialGoal {
        FinancialGoal(stored: self)
    }

    /// Goal type computed property
    var goalType: GoalType {
        GoalType(rawValue: goalTypeRaw) ?? .savingsTarget
    }
}

// MARK: - Domain Model Extension

extension FinancialGoal {
    /// Initialize from stored model
    init(stored: StoredFinancialGoal) {
        self.id = stored.id
        self.name = stored.name
        self.goalType = stored.goalType
        self.targetAmount = Decimal(string: stored.targetAmountString) ?? 0
        self.currentAmount = Decimal(string: stored.currentAmountString) ?? 0
        self.currency = stored.currency
        self.targetDate = stored.targetDate
        self.createdAt = stored.createdAt
        self.updatedAt = stored.updatedAt
        self.notes = stored.notes
        self.linkedItemId = stored.linkedItemId
    }

    /// Convert to stored model
    func toStoredFinancialGoal() -> StoredFinancialGoal {
        StoredFinancialGoal(
            id: id ?? UUID().uuidString,
            name: name,
            goalType: goalType,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            currency: currency,
            targetDate: targetDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            notes: notes,
            linkedItemId: linkedItemId
        )
    }
}

// MARK: - Stored Net Worth Snapshot

/// SwiftData model for net worth snapshots
@Model
final class StoredNetWorthSnapshot {
    @Attribute(.unique) var id: String
    var date: Date
    var totalAssetsString: String
    var totalLiabilitiesString: String
    var currency: String
    var assetsByTypeJSON: String?
    var liabilitiesByTypeJSON: String?

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        totalAssets: Decimal = 0,
        totalLiabilities: Decimal = 0,
        currency: String = "USD",
        assetsByTypeJSON: String? = nil,
        liabilitiesByTypeJSON: String? = nil
    ) {
        self.id = id
        self.date = date
        self.totalAssetsString = "\(totalAssets)"
        self.totalLiabilitiesString = "\(totalLiabilities)"
        self.currency = currency
        self.assetsByTypeJSON = assetsByTypeJSON
        self.liabilitiesByTypeJSON = liabilitiesByTypeJSON
    }

    /// Convert to domain model
    func toNetWorthSnapshot() -> NetWorthSnapshot {
        NetWorthSnapshot(stored: self)
    }
}

// MARK: - Domain Model Extension

extension NetWorthSnapshot {
    /// Initialize from stored model
    init(stored: StoredNetWorthSnapshot) {
        self.id = stored.id
        self.date = stored.date
        self.totalAssets = Decimal(string: stored.totalAssetsString) ?? 0
        self.totalLiabilities = Decimal(string: stored.totalLiabilitiesString) ?? 0
        self.currency = stored.currency
        self.assetsByType = Self.decodeBreakdown(from: stored.assetsByTypeJSON)
        self.liabilitiesByType = Self.decodeBreakdown(from: stored.liabilitiesByTypeJSON)
    }

    /// Convert to stored model
    func toStoredNetWorthSnapshot() -> StoredNetWorthSnapshot {
        StoredNetWorthSnapshot(
            id: id ?? UUID().uuidString,
            date: date,
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            currency: currency,
            assetsByTypeJSON: assetsByTypeJSON(),
            liabilitiesByTypeJSON: liabilitiesByTypeJSON()
        )
    }
}

// MARK: - Stored Finance Settings

/// SwiftData model for finance settings
@Model
final class StoredFinanceSettings {
    @Attribute(.unique) var id: String
    var baseCurrency: String
    var updateReminderFrequencyRaw: String
    var updateRemindersEnabled: Bool
    var lastReminderDate: Date?

    init(
        id: String = "settings",
        baseCurrency: String = "USD",
        updateReminderFrequency: UpdateReminderFrequency = .monthly,
        updateRemindersEnabled: Bool = false,
        lastReminderDate: Date? = nil
    ) {
        self.id = id
        self.baseCurrency = baseCurrency
        self.updateReminderFrequencyRaw = updateReminderFrequency.rawValue
        self.updateRemindersEnabled = updateRemindersEnabled
        self.lastReminderDate = lastReminderDate
    }

    /// Convert to domain model
    func toFinanceSettings() -> FinanceSettings {
        FinanceSettings(stored: self)
    }

    /// Update reminder frequency computed property
    var updateReminderFrequency: UpdateReminderFrequency {
        UpdateReminderFrequency(rawValue: updateReminderFrequencyRaw) ?? .monthly
    }
}

// MARK: - Domain Model Extension

extension FinanceSettings {
    /// Initialize from stored model
    init(stored: StoredFinanceSettings) {
        self.id = stored.id
        self.baseCurrency = stored.baseCurrency
        self.updateReminderFrequency = stored.updateReminderFrequency
        self.updateRemindersEnabled = stored.updateRemindersEnabled
        self.lastReminderDate = stored.lastReminderDate
    }

    /// Convert to stored model
    func toStoredFinanceSettings() -> StoredFinanceSettings {
        StoredFinanceSettings(
            id: id ?? "settings",
            baseCurrency: baseCurrency,
            updateReminderFrequency: updateReminderFrequency,
            updateRemindersEnabled: updateRemindersEnabled,
            lastReminderDate: lastReminderDate
        )
    }
}
