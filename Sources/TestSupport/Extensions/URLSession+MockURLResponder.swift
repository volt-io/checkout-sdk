//
// URLSession+MockURLResponder.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

extension URLSession {
    /// Creates `URLSession` with custom `URLProtocol`.
    /// - Parameter mockResponder: Mock responder used with mocked `URLProtocol`.
    package convenience init<T: MockURLResponder>(mockResponder _: T.Type) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol<T>.self]
        self.init(configuration: config)
        URLProtocol.registerClass(MockURLProtocol<T>.self)
    }
}
