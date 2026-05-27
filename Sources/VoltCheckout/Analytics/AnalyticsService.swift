//
// AnalyticsService.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking

final class AnalyticsService: APIServiceProvider, Sendable {
    let client: APIClient

    init(
        requestInterceptors: [RequestInterceptor] = [],
        responseInterceptors: [ResponseInterceptor] = [],
        session: URLSession = .shared
    ) {
        self.client = APIClient(
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors,
            session: session
        )
    }
}

extension AnalyticsService {
    /// Send Mixpanel tracking event with tracking data.
    /// - Parameter event: Event to send.
    func send(_ event: Event) async throws {
        try await client.request(.trackEvent.with(body: [event]))
    }
}

extension AnalyticsService {
    /// Mixpanel host.
    struct Host: HTTPHost {
        static let authority = "mp.volt.io"
    }
}

extension HTTPEndpoint where Host == AnalyticsService.Host {
    /// Mixpanel endpoint for tracking events.
    static var trackEvent: Self {
        .init(method: .post, path: "/track", headers: [
            .contentType: "application/json; charset=utf-8",
            .connection: "Keep-Alive",
            .acceptEncoding: "gzip",
        ])
    }
}
