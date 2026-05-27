//
// ResponseInterceptor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes

/// A response interceptor protocol used to represent types that modify `HTTPResponse` and corresponding data.
package protocol ResponseInterceptor: Sendable {
    /// Method that modifies the response and its data, passed as an `inout` parameters.
    /// - Parameters:
    ///   - httpRequest: Request associated with the response (read-only).
    ///   - httpResponse: Response that can be modified.
    ///   - data: Modifiable data that came with the response.
    func intercept(
        _ httpRequest: HTTPRequest,
        _ httpResponse: inout HTTPResponse,
        with data: inout Data
    ) async throws(APIClientError)
}
