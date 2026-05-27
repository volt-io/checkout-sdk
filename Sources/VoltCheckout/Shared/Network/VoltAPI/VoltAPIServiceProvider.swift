//
// VoltAPIServiceProvider.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 09/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking

protocol VoltAPIServiceProvider: APIServiceProvider {
    func getInstitutionsCountries(currency: String) async throws -> [CountryResponse]
    func getInstitutions(currency: String, country: String) async throws -> [InstitutionResponse]
    func getInstitution(id: String) async throws -> InstitutionResponse
    func createPayment(request: PaymentRequest) async throws -> PaymentResponse
    func getPayment(paymentId: String, paymentToken: String) async throws -> PaymentResponse
    func cancelPayment(paymentId: String, paymentToken: String) async throws
}

extension VoltAPIService: VoltAPIServiceProvider {
    func getInstitutionsCountries(currency: String) async throws -> [CountryResponse] {
        let endpoint: HTTPEndpoint<Host> = .getInstitutionsCountries(
            authToken: try await authTokenProvider(),
            currency: currency
        )
        return try await client.request([CountryResponse].self, from: endpoint)
    }

    func getInstitutions(currency: String, country: String) async throws -> [InstitutionResponse] {
        let endpoint: HTTPEndpoint<Host> = .getInstitutions(
            authToken: try await authTokenProvider(),
            currency: currency,
            country: country,
        )
        return try await client.request([InstitutionResponse].self, from: endpoint)
    }
    
    func getInstitution(id: String) async throws -> InstitutionResponse {
        let endpoint: HTTPEndpoint<Host> = .getInstitution(
            authToken: try await authTokenProvider(),
            id: id
        )
        return try await client.request(InstitutionResponse.self, from: endpoint)
    }

    func createPayment(request: PaymentRequest) async throws -> PaymentResponse {
        let endpoint: HTTPEndpoint<Host> = try .createPayment(
            authToken: try await authTokenProvider(),
            payment: request
        )
        return try await client.request(PaymentResponse.self, from: endpoint)
    }

    func getPayment(paymentId: String, paymentToken: String) async throws -> PaymentResponse {
        let endpoint: HTTPEndpoint<Host> = .getPayment(
            paymentId: paymentId,
            paymentToken: paymentToken
        )
        return try await client.request(PaymentResponse.self, from: endpoint)
    }

    func cancelPayment(paymentId: String, paymentToken: String) async throws {
        let endpoint: HTTPEndpoint<Host> = .cancelPayment(
            paymentId: paymentId,
            paymentToken: paymentToken
        )
        try await client.request(endpoint)
    }
}
