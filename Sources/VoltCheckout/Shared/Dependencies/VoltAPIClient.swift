//
// VoltAPI.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 21/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct VoltAPIClient {
    var getInstitutionsCountries: @Sendable (
        _ currency: Currency
    ) async throws -> [Country]

    var getInstitutions: @Sendable (
        _ currency: Currency,
        _ country: Country
    ) async throws -> [Institution.Item]

    var getInstitution: @Sendable (
        _ id: String
    ) async throws -> Institution.Item

    var createPayment: @Sendable (
        _ request: PaymentRequest
    ) async throws -> PaymentResponse

    var getPayment: @Sendable (
        _ paymentId: String,
        _ paymentToken: String
    ) async throws -> PaymentResponse

    var cancelPayment: @Sendable (
        _ paymentId: String,
        _ paymentToken: String
    ) async throws -> Void
}

extension VoltAPIClient {
    init(with service: VoltAPIServiceProvider) {
        self.init { currency in
            try await service
                .getInstitutionsCountries(currency: currency.rawValue)
                .compactMap { Country(rawValue: $0.code) }
        } getInstitutions: { currency, country in
            try await service
                .getInstitutions(currency: currency.rawValue, country: country.rawValue)
                .map(Institution.Item.init(with:))
        } getInstitution: { id in
            Institution.Item(with: try await service.getInstitution(id: id))
        } createPayment: { request in
            try await service.createPayment(request: request)
        } getPayment: { paymentId, paymentToken in
            try await service.getPayment(paymentId: paymentId, paymentToken: paymentToken)
        } cancelPayment: { paymentId, paymentToken in
            try await service.cancelPayment(paymentId: paymentId, paymentToken: paymentToken)
        }
    }
}

extension DependencyValues {
    var voltAPI: VoltAPIClient {
        get { self[VoltAPIClient.self] }
        set { self[VoltAPIClient.self] = newValue }
    }
}

extension VoltAPIClient: DependencyKey {
    static var liveValue: Self {
        preconditionFailure("Live value of VoltAPIClient needs to be configured before being accessed.")
    }
}

#if DEBUG
import TestSupport

extension VoltAPIClient: TestDependencyKey {
    init(with clock: any Clock<Duration>) {
        self.init { _ in
            try await clock.sleep(for: .seconds(0.5))
            return try ResourceReader
                .readJSON("InstitutionsCountries", to: [CountryResponse].self)
                .compactMap { Country(rawValue: $0.code) }
        } getInstitutions: { _, country in
            try await clock.sleep(for: .seconds(0.5))
            let responseJSON: String
            switch country.locale {
            case .unitedKingdom:
                responseJSON = "InstitutionsListGB"
            case .germany:
                responseJSON = "InstitutionsListDE"
            default:
                responseJSON = "ErrorResponse"
            }
            return try ResourceReader
                .readJSON(responseJSON, to: [InstitutionResponse].self)
                .map(Institution.Item.init(with:))
        } getInstitution: { institutionId in
            try await clock.sleep(for: .seconds(0.5))
            let responseJSON: String
            switch institutionId {
            case "dd7ccb61-7a56-4868-ade2-7d8c633e4106":
                responseJSON = "InstitutionResponse-5"
            case "3426d1bf-9a66-44da-b758-ff324a6faba8":
                responseJSON = "InstitutionResponse-4"
            case "b68537bc-89a1-49f6-b59a-af99dd05e573":
                responseJSON = "InstitutionResponse-3"
            case "15ed231c-56e4-46d5-aa7b-92f1a6eb982f":
                responseJSON = "InstitutionResponse-2"
            default:
                responseJSON = "InstitutionResponse"
            }
            let response = try ResourceReader.readJSON(responseJSON, to: InstitutionResponse.self)
            return Institution.Item(with: response)
        } createPayment: { _ in
            try await clock.sleep(for: .seconds(0.5))
            return try ResourceReader.readJSON("PaymentResponse-1", to: PaymentResponse.self)
        } getPayment: { _, _ in
            try await clock.sleep(for: .seconds(0.5))
            return try ResourceReader.readJSON("PaymentResponse-3", to: PaymentResponse.self)
        } cancelPayment: { _, _ in
            try await clock.sleep(for: .seconds(0.5))
        }
    }

    static let previewValue = Self(with: ContinuousClock())
    static let testValue = Self(with: ImmediateClock())
}
#endif
