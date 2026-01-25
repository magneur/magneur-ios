//
//  FinancialItem.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation

/// Domain model for all financial items (assets and liabilities)
/// Unified value type that can represent any financial item type
struct FinancialItem: Identifiable, Equatable, Hashable {
    var id: String?
    var itemType: FinancialItemType
    var name: String
    var notes: String
    var currency: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Value Properties

    /// Manual value entry (for items without live pricing)
    var manualValue: Decimal

    // MARK: - Live Price Properties

    /// Ticker symbol (for stocks, ETFs)
    var ticker: String?

    /// Coin ID (for crypto, e.g., "bitcoin")
    var coinId: String?

    /// Metal type (for precious metals)
    var metalType: MetalType?

    /// Quantity of units (shares, coins, ounces)
    var quantity: Decimal

    /// Last fetched price per unit
    var lastFetchedPrice: Decimal?

    /// When the price was last updated
    var lastPriceUpdate: Date?

    // MARK: - Liability Properties

    /// Original loan/debt amount
    var originalAmount: Decimal?

    /// Annual interest rate (as decimal, e.g., 0.05 for 5%)
    var interestRate: Decimal?

    /// Minimum monthly payment
    var minimumPayment: Decimal?

    /// Payment due date (day of month)
    var dueDay: Int?

    // MARK: - Real Estate Properties

    /// Property address
    var address: String?

    /// Purchase price
    var purchasePrice: Decimal?

    /// Purchase date
    var purchaseDate: Date?

    // MARK: - Account Properties

    /// Account type (for retirement, e.g., "401k", "IRA")
    var accountType: String?

    /// Institution name
    var institution: String?

    // MARK: - Initializers

    init(
        id: String? = nil,
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
        self.itemType = itemType
        self.name = name
        self.notes = notes
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.manualValue = manualValue
        self.ticker = ticker
        self.coinId = coinId
        self.metalType = metalType
        self.quantity = quantity
        self.lastFetchedPrice = lastFetchedPrice
        self.lastPriceUpdate = lastPriceUpdate
        self.originalAmount = originalAmount
        self.interestRate = interestRate
        self.minimumPayment = minimumPayment
        self.dueDay = dueDay
        self.address = address
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
        self.accountType = accountType
        self.institution = institution
    }

    // MARK: - Factory Methods

    /// Create a cash/savings account
    static func cashSavings(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        institution: String? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .cashSavings,
            name: name,
            currency: currency,
            manualValue: balance,
            institution: institution
        )
    }

    /// Create a real estate asset
    static func realEstate(
        name: String = "",
        value: Decimal = 0,
        currency: String = "USD",
        address: String? = nil,
        purchasePrice: Decimal? = nil,
        purchaseDate: Date? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .realEstate,
            name: name,
            currency: currency,
            manualValue: value,
            address: address,
            purchasePrice: purchasePrice,
            purchaseDate: purchaseDate
        )
    }

    /// Create a vehicle asset
    static func vehicle(
        name: String = "",
        value: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .vehicle,
            name: name,
            currency: currency,
            manualValue: value
        )
    }

    /// Create a precious metal holding
    static func preciousMetal(
        metalType: MetalType,
        quantity: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .preciousMetal,
            name: metalType.displayName,
            currency: currency,
            metalType: metalType,
            quantity: quantity
        )
    }

    /// Create a stock holding
    static func stock(
        ticker: String = "",
        quantity: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .stock,
            name: ticker,
            currency: currency,
            ticker: ticker,
            quantity: quantity
        )
    }

    /// Create an ETF/mutual fund holding
    static func etfMutualFund(
        ticker: String = "",
        quantity: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .etfMutualFund,
            name: ticker,
            currency: currency,
            ticker: ticker,
            quantity: quantity
        )
    }

    /// Create a bond holding
    static func bond(
        name: String = "",
        value: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .bond,
            name: name,
            currency: currency,
            manualValue: value
        )
    }

    /// Create a cryptocurrency holding
    static func crypto(
        coinId: String = "",
        name: String = "",
        quantity: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .crypto,
            name: name,
            currency: currency,
            coinId: coinId,
            quantity: quantity
        )
    }

    /// Create a business equity holding
    static func businessEquity(
        name: String = "",
        value: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .businessEquity,
            name: name,
            currency: currency,
            manualValue: value
        )
    }

    /// Create a retirement account
    static func retirementAccount(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        accountType: String? = nil,
        institution: String? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .retirementAccount,
            name: name,
            currency: currency,
            manualValue: balance,
            accountType: accountType,
            institution: institution
        )
    }

    /// Create another asset type
    static func otherAsset(
        name: String = "",
        value: Decimal = 0,
        currency: String = "USD"
    ) -> FinancialItem {
        FinancialItem(
            itemType: .otherAsset,
            name: name,
            currency: currency,
            manualValue: value
        )
    }

    /// Create a mortgage liability
    static func mortgage(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        originalAmount: Decimal? = nil,
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil,
        address: String? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .mortgage,
            name: name,
            currency: currency,
            manualValue: balance,
            originalAmount: originalAmount,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay,
            address: address
        )
    }

    /// Create an auto loan liability
    static func autoLoan(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        originalAmount: Decimal? = nil,
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .autoLoan,
            name: name,
            currency: currency,
            manualValue: balance,
            originalAmount: originalAmount,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay
        )
    }

    /// Create a student loan liability
    static func studentLoan(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        originalAmount: Decimal? = nil,
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .studentLoan,
            name: name,
            currency: currency,
            manualValue: balance,
            originalAmount: originalAmount,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay
        )
    }

    /// Create a credit card liability
    static func creditCard(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .creditCard,
            name: name,
            currency: currency,
            manualValue: balance,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay
        )
    }

    /// Create a personal loan liability
    static func personalLoan(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        originalAmount: Decimal? = nil,
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .personalLoan,
            name: name,
            currency: currency,
            manualValue: balance,
            originalAmount: originalAmount,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay
        )
    }

    /// Create a business loan liability
    static func businessLoan(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        originalAmount: Decimal? = nil,
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .businessLoan,
            name: name,
            currency: currency,
            manualValue: balance,
            originalAmount: originalAmount,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay
        )
    }

    /// Create a medical debt liability
    static func medicalDebt(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        originalAmount: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .medicalDebt,
            name: name,
            currency: currency,
            manualValue: balance,
            originalAmount: originalAmount,
            minimumPayment: minimumPayment,
            dueDay: dueDay
        )
    }

    /// Create another liability type
    static func otherLiability(
        name: String = "",
        balance: Decimal = 0,
        currency: String = "USD",
        originalAmount: Decimal? = nil,
        interestRate: Decimal? = nil,
        minimumPayment: Decimal? = nil,
        dueDay: Int? = nil
    ) -> FinancialItem {
        FinancialItem(
            itemType: .otherLiability,
            name: name,
            currency: currency,
            manualValue: balance,
            originalAmount: originalAmount,
            interestRate: interestRate,
            minimumPayment: minimumPayment,
            dueDay: dueDay
        )
    }

    // MARK: - Computed Properties

    /// The current value of the item
    /// For live-priced items, uses quantity * price; otherwise uses manual value
    var currentValue: Decimal {
        if itemType.supportsLivePrice, let price = lastFetchedPrice, quantity > 0 {
            return quantity * price
        }
        return manualValue
    }

    /// Display name for the item
    var displayName: String {
        if !name.isEmpty { return name }
        return itemType.displayName
    }

    /// Whether this item has meaningful data
    var hasContent: Bool {
        !name.isEmpty || manualValue != 0 || quantity > 0
    }

    /// Payoff progress for liabilities (0.0 to 1.0)
    var payoffProgress: Double? {
        guard itemType.isLiability,
              let original = originalAmount,
              original > 0 else { return nil }
        let paid = original - manualValue
        return Double(truncating: (paid / original) as NSDecimalNumber)
    }

    /// Whether the price is stale (older than 15 minutes)
    var isPriceStale: Bool {
        guard let lastUpdate = lastPriceUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) > 900 // 15 minutes
    }

    /// Formatted current value string
    func formattedValue(currencyCode: String? = nil) -> String {
        let code = currencyCode ?? currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: currentValue as NSDecimalNumber) ?? "\(code) \(currentValue)"
    }

    /// Formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }

    /// Formatted last price update
    var formattedLastUpdate: String? {
        guard let date = lastPriceUpdate else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Metal Type

enum MetalType: String, CaseIterable, Codable, Identifiable {
    case gold = "XAU"
    case silver = "XAG"
    case platinum = "platinum"
    case palladium = "palladium"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gold: return "Gold"
        case .silver: return "Silver"
        case .platinum: return "Platinum"
        case .palladium: return "Palladium"
        }
    }

    var symbol: String { rawValue }

    /// Whether this metal has a free API for live prices
    var hasFreePricing: Bool {
        switch self {
        case .gold, .silver: return true
        case .platinum, .palladium: return false
        }
    }
}

// MARK: - JSON Encoding

extension FinancialItem {
    /// Encode decimal to string for storage
    static func encodeDecimal(_ value: Decimal?) -> String? {
        guard let value else { return nil }
        return "\(value)"
    }

    /// Decode decimal from string
    static func decodeDecimal(from string: String?) -> Decimal? {
        guard let string else { return nil }
        return Decimal(string: string)
    }
}
