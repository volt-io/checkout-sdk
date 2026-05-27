//
// InterceptorsTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes
import Testing
@testable import HTTPNetworking

@Suite("HeadersInjectorInterceptor Tests")
struct HeadersInjectorInterceptorTests {

    let headers: HTTPFields = [
        .accept: "application/json",
        .contentType: "text/plain; charset=utf-8"
    ]

    @Test("When injecting headers, then these are added to the request")
    func testAddingHeaders() async throws {
        let endpoint = HTTPEndpoint.headersExample
        let expectedHeaders = endpoint.headers + self.headers
        var request = try endpoint.request

        let interceptor = HeadersInjectorInterceptor(headers: self.headers)
        interceptor.intercept(&request)

        #expect(request.headerFields == expectedHeaders)
    }

    @Test("When injecting headers, then existing ones are not overridden")
    func testNotOverridingHeaders() async throws {
        let endpoint = HTTPEndpoint.headersExample
        var request = try endpoint.request

        let interceptor = HeadersInjectorInterceptor(headers: [:])
        interceptor.intercept(&request)

        #expect(request.headerFields == endpoint.headers)
    }
}

@Suite("AuthInjectorInterceptor Tests")
struct AuthInjectorInterceptorTests {

    let tokenProvider: AuthInjectorInterceptor.TokenProvider

    init() {
        tokenProvider = {
            TestConstants.authToken
        }
    }

    @Test("When injecting auth header, then authorization with provided token is added to the request")
    func testAddingAuthHeaders() async throws {
        let endpoint = HTTPEndpoint.getExample
        var request = try endpoint.request

        let interceptor = AuthInjectorInterceptor(provider: tokenProvider)
        try await interceptor.intercept(&request)

        #expect(request.headerFields.contains(.authorization))
        #expect(request.headerFields[.authorization] == "Bearer \(TestConstants.authToken)")
    }

    @Test("When injecting auth header, then it replaces existing one in the request")
    func testOverridingAuthHeader() async throws {
        let endpoint = HTTPEndpoint.headersExample
        var request = try endpoint.request

        let interceptor = AuthInjectorInterceptor(provider: tokenProvider)
        try await interceptor.intercept(&request)

        #expect(request.headerFields != endpoint.headers)
        #expect(request.headerFields.contains(.authorization))
        #expect(request.headerFields[.authorization] == "Bearer \(TestConstants.authToken)")
    }
}
