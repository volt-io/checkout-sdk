//
// Payer.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// Payer information.
public struct Payer: Hashable, Equatable, Codable, Sendable {
    /// Your unique reference for the payer, e.g. customer ID or email address.
    public let reference: Reference

    /// An entity representing payer. This can be a person or organization.
    public let entity: Entity

    /// Payer email address.
    public let email: String?

    /// Phone number, in E.164 format.
    public let phone: String?
    
    /// Creates payer information.
    /// - Parameters:
    ///   - reference: Your unique reference for the payer, e.g. customer ID or email address.
    ///   - entity: An entity representing payer. This can be a person or organization.
    ///   - email: Payer email address.
    ///   - phone: Phone number, in E.164 format.
    public init(reference: Reference, entity: Entity, email: String? = nil, phone: String? = nil) {
        self.reference = reference
        self.entity = entity
        self.email = email
        self.phone = phone
    }
}

extension Payer {
    /// Unique reference of the payer.
    public struct Reference: Hashable, Equatable, Codable, Sendable {
        /// Value of the reference.
        /// It can feature a combination of letters and numbers, along with an optional single @ symbol
        /// and a curated selection of special characters like `!$#%^&*.-_`.
        /// Please, note that special characters are not permitted at the end of the reference value,
        /// and the @ symbol is only allowed in the middle of the reference value.
        public let value: String

        nonisolated(unsafe)
        private static let pattern = /^[a-zA-Z0-9.!#$%&\'\*+\/\=?^_`{|}~-]+@?[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/

        /// Creates a reference from provided value. Returns `nil` if value is not valid.
        /// - Parameter value: Reference value.
        ///
        /// Value has to be up to 255 characters long and match against following regex pattern:
        /// `^[a-zA-Z0-9.!#$%&\'\*+\/\=?^_`{|}~-]+@?[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$`
        public init?(_ value: String) {
            guard value.count <= 255, value.wholeMatch(of: Self.pattern) != nil else { return nil }

            self.value = value
        }

        enum CodingKeys: String, CodingKey {
            case value
        }
    }
    
    /// Person representing a payer.
    public struct Person: Hashable, Equatable, Codable, Sendable {
        /// First name.
        public let firstName: String

        /// Last name.
        public let lastName: String
        
        /// Creates a person from given values. Returns `nil` if any of the values is not valid.
        /// - Parameters:
        ///   - firstName: First name.
        ///   - lastName: Last name.
        ///
        /// Both values has to be up to 255 characters long.
        public init?(firstName: String, lastName: String) {
            guard firstName.count <= 255, lastName.count <= 255 else { return nil }

            self.firstName = firstName
            self.lastName = lastName
        }
    }

    /// Organization representing a payer
    public struct Organization: Hashable, Equatable, Codable, Sendable {
        /// Organization name.
        public let name: String
        
        /// Creates an organization from given value. Returns `nil` if value is not valid.
        /// - Parameter name: Organization name
        ///
        /// Name has to be up to 255 characters long.
        public init?(name: String) {
            guard name.count <= 255 else { return nil }

            self.name = name
        }
    }

    /// Entity representing a payer.
    /// Payer can be represented by a person, an organization, or both.
    public enum Entity: Hashable, Equatable, Codable, Sendable {
        case person(Person),
             organization(Organization),
             both(Person, Organization)
    }
}
