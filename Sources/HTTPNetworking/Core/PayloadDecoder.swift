//
// PayloadDecoder.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 17/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// A protocol that abstracts decoders from their concrete types.
///
/// Any decoder can be extended with conformance to `PayloadDecoder`, to be used for decoding request responses.
package protocol PayloadDecoder: Sendable {
    /// Decodes a top-level value of the given type from the given data representation.
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - from: The data to decode from.
    /// - Returns: A value of the requested type.
    /// - Throws: Decoding errors.
    func decode<T>(_ type: T.Type, from: Data) throws -> T where T: Decodable
}
