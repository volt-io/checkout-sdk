//
// MockDataResponse.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport

struct MockDataResponse: Codable, Equatable {
    var title: String
    var message: String
}

extension MockDataResponse {
    static let testResponse = MockDataResponse(title: "Test Response", message: "Success")
    static let correctData = try? JSONEncoder().encode(testResponse)
    static let malformedData = "malformed response json".data(using: .utf8)

    static func httpResponse(for request: URLRequest) throws -> HTTPURLResponse? {
        HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
    }

    struct MockDataURLResponder: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (correctData, try httpResponse(for: request))
        }
    }

    struct MockMalformedDataURLResponder: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (malformedData, try httpResponse(for: request))
        }
    }
}
