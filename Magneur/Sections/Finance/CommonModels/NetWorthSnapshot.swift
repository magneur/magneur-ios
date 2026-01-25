//
//  NetWorthSnapshot.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation

/// Represents a point-in-time snapshot of net worth for historical tracking
struct NetWorthSnapshot: Identifiable, Equatable, Hashable {
    var id: String?
    var date: Date
    var totalAssets: Decimal
    var totalLiabilities: Decimal
    var currency: String

    /// Breakdown by asset type (stored as JSON)
    var assetsByType: [String: Decimal]

    /// Breakdown by liability type (stored as JSON)
    var liabilitiesByType: [String: Decimal]

    // MARK: - Initializers

    init(
        id: String? = nil,
        date: Date = Date(),
        totalAssets: Decimal = 0,
        totalLiabilities: Decimal = 0,
        currency: String = "USD",
        assetsByType: [String: Decimal] = [:],
        liabilitiesByType: [String: Decimal] = [:]
    ) {
        self.id = id
        self.date = date
        self.totalAssets = totalAssets
        self.totalLiabilities = totalLiabilities
        self.currency = currency
        self.assetsByType = assetsByType
        self.liabilitiesByType = liabilitiesByType
    }

    // MARK: - Computed Properties

    /// Net worth (assets - liabilities)
    var netWorth: Decimal {
        totalAssets - totalLiabilities
    }

    /// Formatted net worth string
    func formattedNetWorth(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: netWorth as NSDecimalNumber) ?? "\(code) \(netWorth)"
    }

    /// Formatted assets string
    func formattedAssets(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: totalAssets as NSDecimalNumber) ?? "\(code) \(totalAssets)"
    }

    /// Formatted liabilities string
    func formattedLiabilities(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: totalLiabilities as NSDecimalNumber) ?? "\(code) \(totalLiabilities)"
    }

    /// Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // MARK: - Factory Methods

    /// Create a snapshot from current financial items
    static func create(
        from items: [FinancialItem],
        currency: String = "USD"
    ) -> NetWorthSnapshot {
        let assets = items.filter { $0.itemType.isAsset }
        let liabilities = items.filter { $0.itemType.isLiability }

        let totalAssets = assets.reduce(Decimal(0)) { $0 + $1.currentValue }
        let totalLiabilities = liabilities.reduce(Decimal(0)) { $0 + $1.currentValue }

        var assetsByType: [String: Decimal] = [:]
        for asset in assets {
            let key = asset.itemType.rawValue
            assetsByType[key, default: 0] += asset.currentValue
        }

        var liabilitiesByType: [String: Decimal] = [:]
        for liability in liabilities {
            let key = liability.itemType.rawValue
            liabilitiesByType[key, default: 0] += liability.currentValue
        }

        return NetWorthSnapshot(
            id: UUID().uuidString,
            date: Date(),
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            currency: currency,
            assetsByType: assetsByType,
            liabilitiesByType: liabilitiesByType
        )
    }
}

// MARK: - JSON Encoding

extension NetWorthSnapshot {
    /// Encode breakdown dictionary to JSON string
    func assetsByTypeJSON() -> String? {
        let stringDict = assetsByType.mapValues { "\($0)" }
        guard let data = try? JSONEncoder().encode(stringDict) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Encode breakdown dictionary to JSON string
    func liabilitiesByTypeJSON() -> String? {
        let stringDict = liabilitiesByType.mapValues { "\($0)" }
        guard let data = try? JSONEncoder().encode(stringDict) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Decode breakdown dictionary from JSON string
    static func decodeBreakdown(from json: String?) -> [String: Decimal] {
        guard let json, let data = json.data(using: .utf8) else { return [:] }
        guard let stringDict = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
        var result: [String: Decimal] = [:]
        for (key, value) in stringDict {
            if let decimal = Decimal(string: value) {
                result[key] = decimal
            }
        }
        return result
    }
}
