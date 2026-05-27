//
// Currency.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 03/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

public import Foundation

/// Currencies supported by Volt payments.
public enum Currency: String, Codable, Sendable, CaseIterable {
    case AUD, EUR, GBP, NOK, PLN, RON, SEK
}

extension Currency {
    /// Currency as `Locale.Currency`.
    public var locale: Locale.Currency {
        .init(rawValue)
    }
}
