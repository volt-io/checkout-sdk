//
// VoltAPIClientTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
@testable import VoltCheckout

@Suite("VoltAPIClient Tests")
struct VoltAPIClientTests {
    let interceptor = MockInterceptor()

    let country = Country(.germany)
    let currency = Currency.EUR
    let institutionId = "2ed2b7e1-6425-4735-91f6-e69a6bd9a7cf"
    let paymentId = "1c3b0160-3b74-46a9-9e48-9a1a61276008"
    let paymentToken = "paymentToken"
    let expectedCountries = try! ResourceReader
        .readJSON("InstitutionsCountries", to: [CountryResponse].self)
        .compactMap { Country(rawValue: $0.code) }

    private func service(
        for mockResponder: MockVoltAPIResponder,
        authToken: String = "test-auth-token")
    -> VoltAPIService<VoltAPISandboxHost> {
        VoltAPIService<VoltAPISandboxHost>(
            authTokenProvider: { authToken },
            requestInterceptors: [interceptor],
            responseInterceptors: [interceptor],
            session: mockResponder.session
        )
    }

    @Test("When getInstitutionsCountries is called, then response is correctly decoded and mapped")
    func testGetInstitutionsCountries() async throws {
        let client = VoltAPIClient(with: service(for: .getInstitutionsCountries))

        await #expect(throws: Never.self, performing: {
            let result = try await client.getInstitutionsCountries(currency: currency)
            #expect(result == expectedCountries)
        })
    }

    @Test("When getInstitutions is called, then response is correctly decoded and mapped")
    func testGetInstitutions() async throws {
        let client = VoltAPIClient(with: service(for: .getInstitutions))

        await #expect(throws: Never.self, performing: {
            let result = try await client.getInstitutions(currency: currency, country: country)
            #expect(result.count == 1122)
        })
    }

    @Test("When getInstitution is called, then response is correctly decoded and mapped")
    func testGetInstitution() async throws {
        let client = VoltAPIClient(with: service(for: .getInstitution))

        await #expect(throws: Never.self, performing: {
            let result = try await client.getInstitution(id: institutionId)
            #expect(result.name == "N26")
            #expect(result.country == .init(.germany))
        })
    }

    @Test("When createPayment is called, then request data is correctly encoded")
    func testCreatePaymentRequest() async throws {
        let client = VoltAPIClient(with: service(for: .createPayment))

        await #expect(throws: Never.self, performing: {
            _ = try await client.createPayment(request: PaymentRequest.testValue)
            let requestBody = try #require(interceptor.interceptedRequestBody)
            let paymentRequest = try JSONDecoder().decode(PaymentRequest.self, from: requestBody)
            #expect(paymentRequest.device.ip == "1.1.1.1")
            #expect(paymentRequest.paymentSystem == .openBankingEU)
        })
    }

    @Test("When createPayment is called, then response is correctly decoded and mapped")
    func testCreatePaymentResponse() async throws {
        let client = VoltAPIClient(with: service(for: .createPayment))

        await #expect(throws: Never.self, performing: {
            let response = try await client.createPayment(request: PaymentRequest.testValue)
            #expect(response.id == paymentId)
        })
    }

    @Test("When getPayment is called, then response is correctly decoded and mapped")
    func testGetPayment() async throws {
        let client = VoltAPIClient(with: service(for: .getPayment))

        await #expect(throws: Never.self, performing: {
            let response = try await client.getPayment(paymentId: paymentId, paymentToken: paymentToken)
            #expect(response.id == paymentId)
        })
    }

    @Test("When cancelPayment is called, then it doesn't throw any errors")
    func testCancelPayment() async throws {
        let client = VoltAPIClient(with: service(for: .cancelPayment))

        await #expect(throws: Never.self, performing: {
            try await client.cancelPayment(paymentId: paymentId, paymentToken: paymentToken)
        })
    }
}
