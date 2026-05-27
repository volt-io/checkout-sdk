//
// AuthInjectorInterceptor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes

package struct AuthInjectorInterceptor: RequestInterceptor {
    package typealias TokenProvider = @Sendable () async throws -> String

    private let tokenProvider: TokenProvider

    package init(provider: @escaping TokenProvider) {
        self.tokenProvider = provider
    }

    package func intercept(_ httpRequest: inout HTTPTypes.HTTPRequest) async throws(APIClientError) {
        var data: Data?
        try await intercept(&httpRequest, with: &data)
    }

    @_disfavoredOverload
    package func intercept(
        _ httpRequest: inout HTTPTypes.HTTPRequest,
        with _: inout Data?
    ) async throws(APIClientError) {
        do {
            httpRequest.headerFields[.authorization] = "Bearer \(try await tokenProvider())"
        } catch {
            throw APIClientError.interceptorError(error)
        }
    }
}
