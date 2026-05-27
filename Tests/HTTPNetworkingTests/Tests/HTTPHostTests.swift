//
// HTTPHostTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
@testable import HTTPNetworking

@Suite("HTTPHost Tests")
struct HTTPHostTests {

    @Test("When inspecting host, then properties are not modified by it")
    func testValidHost() async throws {
        #expect(MockHTTPHost.scheme.rawValue == TestConstants.hostSchemeRawValue)
        #expect(MockHTTPHost.authority == TestConstants.hostAuthority)
    }

    @Test("When inspecting host url, then it should be created without error")
    func testValidHostURL() async throws {
        let url = try MockHTTPHost.url
        #expect(url.absoluteString == TestConstants.hostURLString)
    }

    @Test("When inspecting host with invalid url, then it should throw error")
    func testInvalidHostURL() async throws {
        #expect(throws: URLError(.badURL), performing: {
            try MockInvalidHTTPHost.url
        })
    }
}
