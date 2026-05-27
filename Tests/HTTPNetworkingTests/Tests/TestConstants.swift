//
// TestConstants.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

enum TestConstants {

    static let hostSchemeRawValue = "https"
    static let hostAuthority = "example.com"
    static let hostURLString = "https://example.com"

    static let endpointPath = "/endpoint/path"
    static let endpointQuery = "search=query&filter=item"
    static let endpointHeaders = ["Accept: application/json", "Authorization: Bearer 123"]

    static let authToken = "secret-auth-token"
}
