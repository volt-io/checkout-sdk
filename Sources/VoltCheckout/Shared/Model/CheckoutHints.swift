//
// CheckoutHints.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// Hints used to direct the checkout flow in a way that enables smoother payment experience for the user.'
/// - `useDefaultCountry(Country)`: use this hint to skip country selection,
/// and present institutions from the provided country.
/// - `useInstitution(Institution)`: use this hint to skip institution selection,
/// and proceed directly to processing payment.
public enum CheckoutHints: Hashable, Equatable, Codable, Sendable {
    case useDefaultCountry(Country)
    case useInstitution(Institution)
    case none
}
