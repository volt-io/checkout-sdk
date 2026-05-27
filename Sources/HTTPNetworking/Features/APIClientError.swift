//
// APIClientError.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes

/// Errors thrown by `APIClient`
package enum APIClientError: Error, Sendable {
    case duplicateRequestId,
         interceptorError(Error),
         invalidResponse(HTTPResponse.Status),
         transportError(Error)
}
