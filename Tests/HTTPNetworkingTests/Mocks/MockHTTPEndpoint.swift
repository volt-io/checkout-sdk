//
// MockHTTPEndpoint.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking

extension HTTPEndpoint where Host == MockHTTPHost {
    static var getExample: Self {
        .init(method: .get, path: "/endpoint/path", query: [
            .init(name: "search", value: "query"),
            .init(name: "filter", value: "item")
        ])
    }

    static var postExample: Self {
        .init(method: .post, path: "/endpoint/path", body: MockDataResponse.correctData)
    }

    static var headersExample: Self {
        .init(method: .patch, path: "/endpoint/path", headers: [
            .accept: "application/json",
            .authorization: "Bearer 123"
        ])
    }

    static var getData: Self {
        .init(method: .get, path: "/endpoint/path")
    }
}
