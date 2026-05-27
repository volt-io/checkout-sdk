//
// RequestInterceptor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes

/// A request interceptor protocol used to represent types that modify `HTTPRequest`.
package protocol RequestInterceptor: Sendable {
    /// Method that modifies the request that's passed as an `inout` parameter.
    /// - Parameter httpRequest: Request that can be modified.
    /// - Parameter data: Modifiable request body data.
    func intercept(_ httpRequest: inout HTTPRequest, with data: inout Data?) async throws(APIClientError)
}
