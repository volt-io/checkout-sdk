//
// HTTPHost.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 16/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// A protocol that describes HTTP host.
///
/// Conforming types are used to identify network destinations in a type-checked manner.
public protocol HTTPHost: Sendable, Equatable {
    /// Scheme used by this host. It defaults to `.https`
    static var scheme: HTTPScheme { get }
    /// The authority of the host.
    static var authority: String { get }
}

/// An enum that lists HTTP schemes.
///
/// Supported schemes are: `.http` and `.https`.
public enum HTTPScheme: String, Sendable {
    case http, https
}

extension HTTPHost {
    /// Default scheme for conforming types.
    public static var scheme: HTTPScheme { .https }
}

extension HTTPHost {
    /// A `URL` created from host scheme and authority.
    /// - Throws: `URLError.badURL`.
    public static var url: URL {
        get throws {
            let urlString = "\(scheme)://\(authority)"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            return url
        }
    }
}
