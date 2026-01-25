//
//  FinancialGoal.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation
import SwiftUI

/// Represents a financial goal
struct FinancialGoal: Identifiable, Equatable, Hashable {
    var id: String?
    var name: String
    var goalType: GoalType
    var targetAmount: Decimal
    var currentAmount: Decimal
    var currency: String
    var targetDate: Date?
    var createdAt: Date
    var updatedAt: Date
    var notes: String

    /// Linked item ID (for debt payoff goals)
    var linkedItemId: String?

    // MARK: - Initializers

    init(
        id: String? = nil,
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
        self.goalType = goalType
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.currency = currency
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.linkedItemId = linkedItemId
    }

    // MARK: - Factory Methods

    static func savingsTarget(
        name: String = "",
        targetAmount: Decimal = 0,
        currency: String = "USD",
        targetDate: Date? = nil
    ) -> FinancialGoal {
        FinancialGoal(
            name: name,
            goalType: .savingsTarget,
            targetAmount: targetAmount,
            currency: currency,
            targetDate: targetDate
        )
    }

    static func debtPayoff(
        name: String = "",
        debtAmount: Decimal = 0,
        currency: String = "USD",
        targetDate: Date? = nil,
        linkedItemId: String? = nil
    ) -> FinancialGoal {
        FinancialGoal(
            name: name,
            goalType: .debtPayoff,
            targetAmount: debtAmount,
            currency: currency,
            targetDate: targetDate,
            linkedItemId: linkedItemId
        )
    }

    static func netWorthTarget(
        name: String = "",
        targetAmount: Decimal = 0,
        currency: String = "USD",
        targetDate: Date? = nil
    ) -> FinancialGoal {
        FinancialGoal(
            name: name,
            goalType: .netWorthTarget,
            targetAmount: targetAmount,
            currency: currency,
            targetDate: targetDate
        )
    }

    static func assetPurchase(
        name: String = "",
        targetAmount: Decimal = 0,
        currency: String = "USD",
        targetDate: Date? = nil
    ) -> FinancialGoal {
        FinancialGoal(
            name: name,
            goalType: .assetPurchase,
            targetAmount: targetAmount,
            currency: currency,
            targetDate: targetDate
        )
    }

    // MARK: - Computed Properties

    /// Progress as a percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        let progress = Double(truncating: (currentAmount / targetAmount) as NSDecimalNumber)
        return min(max(progress, 0), 1)
    }

    /// Whether the goal is achieved
    var isAchieved: Bool {
        currentAmount >= targetAmount
    }

    /// Remaining amount to reach goal
    var remainingAmount: Decimal {
        max(targetAmount - currentAmount, 0)
    }

    /// Whether the goal is on track based on target date
    var isOnTrack: Bool? {
        guard let targetDate else { return nil }
        guard !isAchieved else { return true }

        let totalDays = Calendar.current.dateComponents([.day], from: createdAt, to: targetDate).day ?? 1
        let elapsedDays = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0

        guard totalDays > 0 else { return false }

        let expectedProgress = Double(elapsedDays) / Double(totalDays)
        return progressPercentage >= expectedProgress
    }

    /// Projected completion date based on current progress rate
    var projectedCompletionDate: Date? {
        guard !isAchieved else { return Date() }
        guard currentAmount > 0 else { return nil }

        let daysSinceStart = max(Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 1, 1)
        let progressPerDay = Double(truncating: (currentAmount / Decimal(daysSinceStart)) as NSDecimalNumber)

        guard progressPerDay > 0 else { return nil }

        let remainingDays = Int(Double(truncating: remainingAmount as NSDecimalNumber) / progressPerDay)
        return Calendar.current.date(byAdding: .day, value: remainingDays, to: Date())
    }

    /// Whether the goal has meaningful content
    var hasContent: Bool {
        !name.isEmpty || targetAmount > 0
    }

    /// Formatted target amount string
    func formattedTargetAmount(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: targetAmount as NSDecimalNumber) ?? "\(code) \(targetAmount)"
    }

    /// Formatted current amount string
    func formattedCurrentAmount(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: currentAmount as NSDecimalNumber) ?? "\(code) \(currentAmount)"
    }
}

// MARK: - Goal Type

enum GoalType: String, CaseIterable, Codable, Identifiable {
    case savingsTarget = "savingsTarget"
    case debtPayoff = "debtPayoff"
    case netWorthTarget = "netWorthTarget"
    case assetPurchase = "assetPurchase"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .savingsTarget: return "Savings Target"
        case .debtPayoff: return "Debt Payoff"
        case .netWorthTarget: return "Net Worth Target"
        case .assetPurchase: return "Asset Purchase"
        }
    }

    var icon: String {
        switch self {
        case .savingsTarget: return "banknote.fill"
        case .debtPayoff: return "checkmark.circle.fill"
        case .netWorthTarget: return "chart.line.uptrend.xyaxis"
        case .assetPurchase: return "cart.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .savingsTarget: return .green
        case .debtPayoff: return .blue
        case .netWorthTarget: return .purple
        case .assetPurchase: return .orange
        }
    }

    var description: String {
        switch self {
        case .savingsTarget: return "Save a specific amount of money"
        case .debtPayoff: return "Pay off a debt completely"
        case .netWorthTarget: return "Reach a net worth milestone"
        case .assetPurchase: return "Save for a major purchase"
        }
    }
}
