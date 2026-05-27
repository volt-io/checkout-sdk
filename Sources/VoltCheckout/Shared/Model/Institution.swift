//
// Institution.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 08/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

public import Foundation

/// Representation of the financial institution.
public struct Institution: Identifiable, Equatable, Hashable, Codable, Sendable {
    /// Identifier of the institution. A UUID string.
    public let id: String

    /// Name of the institution.
    public let name: String

    /// A URL to the institution logo.
    public let logo: URL?

    /// Institution country.
    public let country: Country

    public init(id: String, name: String, logo: URL? = nil, country: Country) {
        self.id = id
        self.name = name
        self.logo = logo
        self.country = country
    }
}
