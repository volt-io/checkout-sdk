//
// MockURLProtocol.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

package final class MockURLProtocol<Responder: MockURLResponder>: URLProtocol {
    /// Determines whether the protocol subclass can handle the specified request.
    /// - Parameter request: The request to be handled.
    /// - Returns: Always returns `true`.
    package override static func canInit(with _: URLRequest) -> Bool {
        true
    }
    
    /// Returns a canonical version of the specified request.
    /// - Parameter request: The request whose canonical version is desired.
    /// - Returns: This protocol returns unmodified request.
    package override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    /// Starts protocol-specific loading of the request.
    package override final func startLoading() {
        do {
            let (data, response) = try Responder.respond(to: request)

            if let response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data {
                let chunkSize = max(1, data.count / 3)
                for start in stride(from: 0, to: data.count, by: chunkSize) {
                    let chunkEnd = min(start + chunkSize, data.count)
                    client?.urlProtocol(self, didLoad: data[start..<chunkEnd])
                }
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }
    
    /// Stops protocol-specific loading of the request.
    package override final func stopLoading() {
        // no-op
    }
}
