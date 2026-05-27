//
// Country.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 03/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

public import Foundation

/// Country representation.
public struct Country: RawRepresentable, Hashable, Equatable, Codable, Sendable {
    /// Country as `Locale.Region`.
    public let locale: Locale.Region

    /// Country code identifier in ISO 3166 alpha-2 format.
    public var rawValue: String {
        locale.identifier
    }

    /// Creates `Country` from country code identifier.
    /// - Parameter rawValue: Country code identifier in ISO 3166 alpha-2 format.
    public init(rawValue: String) {
        self.locale = Locale.Region(rawValue)
    }
    
    /// Creates `Country` from locale region. Country has to be an ISO region.
    /// - Parameter region: Region from which to create country representation.
    public init(_ region: Locale.Region) {
        self.locale = region
    }
}
