//
// VoltAPIService.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking
import HTTPTypes

final class VoltAPIService<Host>: APIServiceProvider, Sendable where Host: VoltAPIHost {
    typealias VoltHost = Host
    
    let client: APIClient
    let authTokenProvider: VoltCheckout.AuthTokenProvider

    // swiftlint:disable unavailable_function
    init(
        requestInterceptors _: [RequestInterceptor],
        responseInterceptors _: [ResponseInterceptor],
        session _: URLSession
    ) {
        fatalError("Use `init(authTokenProvider:requestInterceptors:responseInterceptors:session:)` initializer.")
    }
    // swiftlint:enable unavailable_function

    init(
        authTokenProvider: @escaping VoltCheckout.AuthTokenProvider,
        requestInterceptors: [RequestInterceptor] = [],
        responseInterceptors: [ResponseInterceptor] = [],
        session: URLSession = .shared
    ) {
        let headersInjector = HeadersInjectorInterceptor(headers: HTTPEndpoint<Host>.commonHeaders)
        self.client = APIClient(
            requestInterceptors: [headersInjector] + requestInterceptors,
            responseInterceptors: responseInterceptors,
            session: session
        )
        self.authTokenProvider = authTokenProvider
    }
}

extension HTTPEndpoint where Host: VoltAPIHost {
    static var commonHeaders: HTTPFields {
        [
            .contentType: "application/json",
            .voltApiVersionHeader: "1",
            .voltInitiationChannelHeader: "mobileSdk",
        ]
    }

    static func getInstitutionsCountries(authToken: String, currency: String) -> Self {
        .init(method: .get, path: "/institutions/countries", headers: [
            .authorization: "Bearer \(authToken)"
        ], query: [
            .init(param: "institution[currency]", value: currency.uppercased()),
        ].compactMap { $0 })
    }

    static func getInstitutions(authToken: String, currency: String, country: String) -> Self {
        .init(method: .get, path: "/institutions", headers: [
            .authorization: "Bearer \(authToken)"
        ], query: [
            .init(param: "currency", value: currency.uppercased()),
            .init(param: "country", value: country.uppercased()),
        ].compactMap { $0 })
    }

    static func getInstitution(authToken: String, id: String) -> Self {
        .init(method: .get, path: "/institutions/\(id)", headers: [
            .authorization: "Bearer \(authToken)"
        ])
    }

    static func createPayment(authToken: String, payment: PaymentRequest) throws -> Self {
        .init(method: .post, path: "/payments", headers: [
            .authorization: "Bearer \(authToken)",
            .idempotencyKeyHeader: UUID().uuidString,
        ], body: try JSONEncoder().encode(payment))
    }

    static func getPayment(paymentId: String, paymentToken: String) -> Self {
        .init(method: .get, path: "/payments/\(paymentId)", headers: [
            .voltAppAuthorizationHeader: "Bearer \(paymentToken)",
            .voltApp: "mobile",
        ])
    }

    static func cancelPayment(paymentId: String, paymentToken: String) -> Self {
        .init(method: .post, path: "/payments/\(paymentId)/cancel", headers: [
            .voltAppAuthorizationHeader: "Bearer \(paymentToken)"
        ])
    }
}
