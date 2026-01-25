//
//  FinancialItemType.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Represents all types of financial items (assets and liabilities)
enum FinancialItemType: String, CaseIterable, Codable, Identifiable {
    // Assets
    case cashSavings = "cashSavings"
    case realEstate = "realEstate"
    case vehicle = "vehicle"
    case preciousMetal = "preciousMetal"
    case stock = "stock"
    case etfMutualFund = "etfMutualFund"
    case bond = "bond"
    case crypto = "crypto"
    case businessEquity = "businessEquity"
    case retirementAccount = "retirementAccount"
    case otherAsset = "otherAsset"

    // Liabilities
    case mortgage = "mortgage"
    case autoLoan = "autoLoan"
    case studentLoan = "studentLoan"
    case creditCard = "creditCard"
    case personalLoan = "personalLoan"
    case businessLoan = "businessLoan"
    case medicalDebt = "medicalDebt"
    case otherLiability = "otherLiability"

    var id: String { rawValue }

    // MARK: - Classification

    var isAsset: Bool {
        switch self {
        case .cashSavings, .realEstate, .vehicle, .preciousMetal, .stock,
             .etfMutualFund, .bond, .crypto, .businessEquity, .retirementAccount, .otherAsset:
            return true
        case .mortgage, .autoLoan, .studentLoan, .creditCard,
             .personalLoan, .businessLoan, .medicalDebt, .otherLiability:
            return false
        }
    }

    var isLiability: Bool { !isAsset }

    /// Whether this type supports live price fetching
    var supportsLivePrice: Bool {
        switch self {
        case .stock, .etfMutualFund, .crypto, .preciousMetal:
            return true
        default:
            return false
        }
    }

    // MARK: - Display

    var displayName: String {
        switch self {
        case .cashSavings: return "Cash & Savings"
        case .realEstate: return "Real Estate"
        case .vehicle: return "Vehicle"
        case .preciousMetal: return "Precious Metal"
        case .stock: return "Stock"
        case .etfMutualFund: return "ETF / Mutual Fund"
        case .bond: return "Bond"
        case .crypto: return "Cryptocurrency"
        case .businessEquity: return "Business Equity"
        case .retirementAccount: return "Retirement Account"
        case .otherAsset: return "Other Asset"
        case .mortgage: return "Mortgage"
        case .autoLoan: return "Auto Loan"
        case .studentLoan: return "Student Loan"
        case .creditCard: return "Credit Card"
        case .personalLoan: return "Personal Loan"
        case .businessLoan: return "Business Loan"
        case .medicalDebt: return "Medical Debt"
        case .otherLiability: return "Other Liability"
        }
    }

    var icon: String {
        switch self {
        case .cashSavings: return "banknote.fill"
        case .realEstate: return "house.fill"
        case .vehicle: return "car.fill"
        case .preciousMetal: return "circle.fill"
        case .stock: return "chart.line.uptrend.xyaxis"
        case .etfMutualFund: return "chart.pie.fill"
        case .bond: return "doc.text.fill"
        case .crypto: return "bitcoinsign.circle.fill"
        case .businessEquity: return "building.2.fill"
        case .retirementAccount: return "umbrella.fill"
        case .otherAsset: return "cube.fill"
        case .mortgage: return "house"
        case .autoLoan: return "car"
        case .studentLoan: return "graduationcap.fill"
        case .creditCard: return "creditcard.fill"
        case .personalLoan: return "person.fill"
        case .businessLoan: return "building.2"
        case .medicalDebt: return "cross.fill"
        case .otherLiability: return "cube"
        }
    }

    var accentColor: Color {
        switch self {
        case .cashSavings: return .green
        case .realEstate: return .blue
        case .vehicle: return .orange
        case .preciousMetal: return .yellow
        case .stock: return .purple
        case .etfMutualFund: return .indigo
        case .bond: return .brown
        case .crypto: return .orange
        case .businessEquity: return .cyan
        case .retirementAccount: return .teal
        case .otherAsset: return .gray
        case .mortgage: return .red
        case .autoLoan: return .pink
        case .studentLoan: return .red
        case .creditCard: return .red
        case .personalLoan: return .red
        case .businessLoan: return .red
        case .medicalDebt: return .red
        case .otherLiability: return .red
        }
    }

    var description: String {
        switch self {
        case .cashSavings: return "Bank accounts, savings, and cash holdings"
        case .realEstate: return "Property, land, and real estate investments"
        case .vehicle: return "Cars, boats, motorcycles, and other vehicles"
        case .preciousMetal: return "Gold, silver, platinum holdings"
        case .stock: return "Individual company stocks"
        case .etfMutualFund: return "ETFs and mutual fund investments"
        case .bond: return "Government and corporate bonds"
        case .crypto: return "Bitcoin, Ethereum, and other cryptocurrencies"
        case .businessEquity: return "Ownership stakes in businesses"
        case .retirementAccount: return "401k, IRA, and pension accounts"
        case .otherAsset: return "Other valuable assets"
        case .mortgage: return "Home loan balance"
        case .autoLoan: return "Vehicle financing balance"
        case .studentLoan: return "Education loan balance"
        case .creditCard: return "Credit card balances"
        case .personalLoan: return "Personal loan balance"
        case .businessLoan: return "Business financing balance"
        case .medicalDebt: return "Medical bills and healthcare debt"
        case .otherLiability: return "Other debts and obligations"
        }
    }

    // MARK: - Grouping

    static var assetTypes: [FinancialItemType] {
        allCases.filter { $0.isAsset }
    }

    static var liabilityTypes: [FinancialItemType] {
        allCases.filter { $0.isLiability }
    }

    static var livePriceTypes: [FinancialItemType] {
        allCases.filter { $0.supportsLivePrice }
    }
}
