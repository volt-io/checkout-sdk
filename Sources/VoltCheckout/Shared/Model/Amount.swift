//
// Amount.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// An amount of money in given currency.
public struct Amount: Hashable, Equatable, Codable, Sendable {
    /// Currency in which this amount is represented.
    public let currency: Currency

    /// Amount in minor units of given currency. For all currencies supported by Volt minor unit is 1/100.
    public let minorUnits: UInt
    
    /// Creates an amount of money in given currency.
    /// - Parameters:
    ///   - currency: Currency in which this amount is represented.
    ///   - minorUnits: Amount in minor units of given currency.
    ///
    /// For all currencies supported by Volt minor unit is 1/100.
    /// Amount of `minorUnits` has to be greater than zero, otherwise initializer will return `nil`.
    public init?(currency: Currency, minorUnits: UInt) {
        guard minorUnits > 0 else { return nil }

        self.currency = currency
        self.minorUnits = minorUnits
    }
}
