//
// HTTPEndpointTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
@testable import HTTPNetworking

@Suite("HTTPEndpoint Tests")
struct HTTPEndpointTests {

    @Test("When inspecting GET endpoint, then it has correct method, path and query")
    func testGetEndpoint() async throws {
        let endpoint = HTTPEndpoint.getExample

        #expect(endpoint.method == .get)
        #expect(endpoint.path == TestConstants.endpointPath)

        let url = try endpoint.url
        #expect(url.query() == TestConstants.endpointQuery)
    }

    @Test("When creating request from GET endpoint, then it has correct method, url and headers")
    func testGetEndpointRequest() async throws {
        let endpoint = HTTPEndpoint.getExample

        let request = try endpoint.request
        #expect(endpoint.method == request.method)
        #expect(try endpoint.url == request.url)
        #expect(endpoint.headers == request.headerFields)
    }

    @Test("When inspecting POST endpoint, then it has correct method, path and body data")
    func testPostEndpoint() async throws {
        let endpoint = HTTPEndpoint.postExample

        #expect(endpoint.method == .post)
        #expect(endpoint.path == TestConstants.endpointPath)
        #expect(endpoint.body == MockDataResponse.correctData)
    }

    @Test("When creating request from POST endpoint, then it has correct method, url and headers")
    func testPostEndpointRequest() async throws {
        let endpoint = HTTPEndpoint.postExample

        let request = try endpoint.request
        #expect(endpoint.method == request.method)
        #expect(try endpoint.url == request.url)
        #expect(endpoint.headers == request.headerFields)
    }

    @Test("When inspecting endpoint with headers, then it has correct method, path and headers")
    func testHeadersEndpoint() async throws {
        let endpoint = HTTPEndpoint.headersExample

        #expect(endpoint.method == .patch)
        #expect(endpoint.path == TestConstants.endpointPath)
        #expect(endpoint.headers.map(\.description) == TestConstants.endpointHeaders)
    }

    @Test("When creating request from endpoint with headers, then it has correct method, url and headers")
    func testHeadersEndpointRequest() async throws {
        let endpoint = HTTPEndpoint.headersExample

        let request = try endpoint.request
        #expect(endpoint.method == request.method)
        #expect(try endpoint.url == request.url)
        #expect(endpoint.headers == request.headerFields)
    }
}
