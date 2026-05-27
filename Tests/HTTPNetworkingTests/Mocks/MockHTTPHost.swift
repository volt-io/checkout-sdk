//
// MockHTTPHost.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking

struct MockHTTPHost: HTTPHost {
    static let authority: String = "example.com"
}

struct MockInvalidHTTPHost: HTTPHost {
    static let authority: String = "<invalid authority>"
}
