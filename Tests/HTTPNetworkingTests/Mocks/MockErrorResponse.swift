//
// MockError.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
import HTTPNetworking

struct MockNetworkErrorResponder: MockURLResponder {
    static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
        throw URLError(.timedOut)
    }
}

struct MockClientErrorResponder: MockURLResponder {
    static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
        (Data(), HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil
        ))
    }
}

struct MockServerErrorResponder: MockURLResponder {
    static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
        (Data(), HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 503,
            httpVersion: nil,
            headerFields: nil
        ))
    }
}
