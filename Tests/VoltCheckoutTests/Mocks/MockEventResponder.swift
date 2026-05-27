//
// MockEventResponder.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
@testable import VoltCheckout

enum MockEventResponder {
    struct Success: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (nil, HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        }
    }

    struct Failure: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (nil, HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            ))
        }
    }
}



