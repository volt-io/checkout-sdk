//
// APIClientError+Equatable.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 24/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking

extension APIClientError: Equatable {
    package static func == (lhs: APIClientError, rhs: APIClientError) -> Bool {
        switch (lhs, rhs) {
        case (.duplicateRequestId, .duplicateRequestId):
            return true
        case let (.invalidResponse(lhsStatus), .invalidResponse(rhsStatus)) where lhsStatus == rhsStatus:
            return true
        case (.transportError, .transportError):
            return true
        default:
            return false
        }
    }
}
