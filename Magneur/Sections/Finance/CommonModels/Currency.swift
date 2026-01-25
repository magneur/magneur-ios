//
//  Currency.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import Foundation

/// Represents an ISO 4217 currency
struct Currency: Identifiable, Hashable, Codable {
    let code: String
    let name: String
    let symbol: String

    var id: String { code }

    /// Common currencies for easy access
    static let usd = Currency(code: "USD", name: "US Dollar", symbol: "$")
    static let eur = Currency(code: "EUR", name: "Euro", symbol: "€")
    static let gbp = Currency(code: "GBP", name: "British Pound", symbol: "£")
    static let jpy = Currency(code: "JPY", name: "Japanese Yen", symbol: "¥")
    static let cad = Currency(code: "CAD", name: "Canadian Dollar", symbol: "$")
    static let aud = Currency(code: "AUD", name: "Australian Dollar", symbol: "$")
    static let chf = Currency(code: "CHF", name: "Swiss Franc", symbol: "Fr")
    static let cny = Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥")
    static let inr = Currency(code: "INR", name: "Indian Rupee", symbol: "₹")
    static let mxn = Currency(code: "MXN", name: "Mexican Peso", symbol: "$")
    static let brl = Currency(code: "BRL", name: "Brazilian Real", symbol: "R$")
    static let krw = Currency(code: "KRW", name: "South Korean Won", symbol: "₩")
    static let sgd = Currency(code: "SGD", name: "Singapore Dollar", symbol: "$")
    static let hkd = Currency(code: "HKD", name: "Hong Kong Dollar", symbol: "$")
    static let nzd = Currency(code: "NZD", name: "New Zealand Dollar", symbol: "$")
    static let sek = Currency(code: "SEK", name: "Swedish Krona", symbol: "kr")
    static let nok = Currency(code: "NOK", name: "Norwegian Krone", symbol: "kr")
    static let dkk = Currency(code: "DKK", name: "Danish Krone", symbol: "kr")
    static let pln = Currency(code: "PLN", name: "Polish Zloty", symbol: "zł")
    static let ron = Currency(code: "RON", name: "Romanian Leu", symbol: "lei")

    /// List of common currencies
    static let commonCurrencies: [Currency] = [
        .usd, .eur, .gbp, .jpy, .cad, .aud, .chf, .cny, .inr, .mxn,
        .brl, .krw, .sgd, .hkd, .nzd, .sek, .nok, .dkk, .pln, .ron
    ]

    /// All available currencies (can be expanded)
    static let allCurrencies: [Currency] = commonCurrencies

    /// Find currency by code
    static func currency(forCode code: String) -> Currency? {
        allCurrencies.first { $0.code.uppercased() == code.uppercased() }
    }

    /// Format a decimal amount in this currency
    func format(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.currencySymbol = symbol
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(symbol)\(amount)"
    }
}
