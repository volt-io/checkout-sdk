//
// MockURLResponder.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// Mock URL responder that returns arbitrary response, data or error for given request.
package protocol MockURLResponder {
    /// Returns arbitrary data and response for given URL request.
    /// - Parameter request: Incoming URL request.
    /// - Returns: Response data and URL response.
    static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?)
}
