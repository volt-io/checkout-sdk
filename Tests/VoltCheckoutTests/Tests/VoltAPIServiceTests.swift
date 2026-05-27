//
// VoltAPIServiceTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
import HTTPTypes
import HTTPNetworking
@testable import VoltCheckout

@Suite("Volt API Service Tests")
struct VoltAPIServiceTests {
    static let country = "DE"
    static let currency = "EUR"

    let expectedHeaders: [HTTPField.Name] = [.contentType, .voltApiVersionHeader, .voltInitiationChannelHeader]
    let institutionsPath = "/institutions?currency=\(currency)&country=\(country)"
    let institutionPath = "/institutions/2ed2b7e1-6425-4735-91f6-e69a6bd9a7cf?"
    let institutionId = "2ed2b7e1-6425-4735-91f6-e69a6bd9a7cf"
    let tokenProvider: VoltCheckout.AuthTokenProvider = { "fake_auth_token" }
    let paymentId = "497dcba3-ecbf-4587-a2dd-5eb0665e6880"
    let paymentToken = "fake_payment_token"

    private func mockService(
        _ responder: MockURLResponder.Type,
        interceptor: MockInterceptor? = nil
    ) -> VoltAPIService<VoltAPISandboxHost> {
        VoltAPIService<VoltAPISandboxHost>(
            authTokenProvider: tokenProvider,
            requestInterceptors: [interceptor].compactMap { $0 },
            session: URLSession(mockResponder: responder)
        )
    }

    // MARK: - Tests

    @Test("When API service is specialized with host, then correct authority can be read from it")
    func testServiceHost() async throws {
        #expect(VoltAPIService<VoltAPISandboxHost>.VoltHost.authority == VoltAPISandboxHost.authority)
        #expect(VoltAPIService<VoltAPIProductionHost>.VoltHost.authority == VoltAPIProductionHost.authority)
    }

    @Test("When getInstitutions endpoint is called, then it has correct headers and query items")
    func testGetInstitutionsEndpoint() async throws {
        let mockInterceptor = MockInterceptor()
        let service = mockService(MockVoltAPIResponder.GetInstitutions.self, interceptor: mockInterceptor)

        _ = try await service.getInstitutions(currency: Self.currency, country: Self.country)
        let request = try #require(mockInterceptor.interceptedRequest)

        #expect(request.method == .get)
        #expect(request.headerFields.map(\.name).contains(expectedHeaders))
        #expect(request.path == institutionsPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
    }

    @Test("When getInstitutionsCountries is called, then it is decoded to response type without errors")
    func testGetInstitutionsCountriesSuccess() async throws {
        let service = mockService(MockVoltAPIResponder.GetInstitutionsCountries.self)

        await #expect(throws: Never.self, performing: {
            let response = try await service.getInstitutionsCountries(currency: Self.currency)
            #expect(!response.isEmpty)
        })
    }

    @Test("When getInstitutionsCountries returns error, then it is correctly handled by the service")
    func testGetInstitutionsCountriesError() async throws {
        let service = mockService(MockVoltAPIResponder.ErrorForbidden.self)

        await #expect(throws: APIClientError.invalidResponse(.forbidden), performing: {
            _ = try await service.getInstitutionsCountries(currency: Self.currency)
        })
    }

    @Test("When getInstitutions is called, then it is decoded to response type without errors")
    func testGetInstitutionsSuccess() async throws {
        let service = mockService(MockVoltAPIResponder.GetInstitutions.self)

        await #expect(throws: Never.self, performing: {
            let response = try await service.getInstitutions(currency: Self.currency, country: Self.country)
            #expect(!response.isEmpty)
        })
    }

    @Test("When getInstitutions returns error, then it is correctly handled by the service")
    func testGetInstitutionsError() async throws {
        let service = mockService(MockVoltAPIResponder.ErrorForbidden.self)

        await #expect(throws: APIClientError.invalidResponse(.forbidden), performing: {
            _ = try await service.getInstitutions(currency: Self.currency, country: Self.country)
        })
    }

    @Test("When getInstitution endpoint is called, then it has correct headers and properties")
    func testGetInstitutionEndpoint() async throws {
        let mockInterceptor = MockInterceptor()
        let service = mockService(MockVoltAPIResponder.GetInstitution.self, interceptor: mockInterceptor)
        let expectedHeaders = [.authorization] + self.expectedHeaders

        _ = try await service.getInstitution(id: institutionId)
        let request = try #require(mockInterceptor.interceptedRequest)

        #expect(request.method == .get)
        #expect(request.path == institutionPath)
        #expect(request.headerFields.map(\.name).elementsEqual(expectedHeaders))
        #expect(request.headerFields[.authorization] == "Bearer \(try await tokenProvider())")
    }

    @Test("When getInstitution endpoint is called, then it is decoded to response without errors")
    func testGetInstitutionSuccess() async throws {
        let service = mockService(MockVoltAPIResponder.GetInstitution.self)

        await #expect(throws: Never.self, performing: {
            _ = try await service.getInstitution(id: institutionId)
        })
    }

    @Test("When getInstitution returns error, then it is correctly handled by the service")
    func testGetInstitutionError() async throws {
        let service = mockService(MockVoltAPIResponder.ErrorForbidden.self)

        await #expect(throws: APIClientError.invalidResponse(.forbidden), performing: {
            _ = try await service.getInstitution(id: institutionId)
        })
    }

    @Test("When createPayment endpoint is called, then it has correct headers")
    func testCreatePaymentEndpoint() async throws {
        let mockInterceptor = MockInterceptor()
        let service = mockService(MockVoltAPIResponder.CreatePayment.self, interceptor: mockInterceptor)
        let expectedHeaders = [.authorization, .idempotencyKeyHeader] + self.expectedHeaders

        _ = try await service.createPayment(request: PaymentRequest.testValue)
        let request = try #require(mockInterceptor.interceptedRequest)

        #expect(request.method == .post)
        #expect(request.headerFields.map(\.name).elementsEqual(expectedHeaders))
        #expect(request.headerFields[.authorization] == "Bearer \(try await tokenProvider())")
    }

    @Test("When createPayment is called, then it is encoded without errors")
    func testCreatePaymentSuccess() async throws {
        let service = mockService(MockVoltAPIResponder.CreatePayment.self)

        await #expect(throws: Never.self, performing: {
            _ = try await service.createPayment(request: PaymentRequest.testValue)
        })
    }

    @Test("When createPayment returns error, then it is correctly handled by the service")
    func testCreatePaymentError() async throws {
        let service = mockService(MockVoltAPIResponder.ErrorForbidden.self)

        await #expect(throws: APIClientError.invalidResponse(.forbidden), performing: {
            _ = try await service.createPayment(request: PaymentRequest.testValue)
        })
    }

    @Test("When getPayment endpoint is called, then it has correct headers and query items")
    func testGetPaymentEndpoint() async throws {
        let mockInterceptor = MockInterceptor()
        let service = mockService(MockVoltAPIResponder.GetPayment.self, interceptor: mockInterceptor)
        let expectedHeaders = [.voltAppAuthorizationHeader, .voltApp] + self.expectedHeaders

        _ = try await service.getPayment(paymentId: paymentId, paymentToken: paymentToken)
        let request = try #require(mockInterceptor.interceptedRequest)

        #expect(request.method == .get)
        #expect(request.headerFields.map(\.name).elementsEqual(expectedHeaders))
        #expect(request.headerFields[.voltAppAuthorizationHeader] == "Bearer \(paymentToken)")
    }

    @Test("When getPayment is called, then it is decoded to response type without errors")
    func testGetPaymentSuccess() async throws {
        let service = mockService(MockVoltAPIResponder.GetPayment.self)

        await #expect(throws: Never.self, performing: {
            _ = try await service.getPayment(paymentId: paymentId, paymentToken: paymentToken)
        })
    }

    @Test("When getPayment returns error, then it is correctly handled by the service")
    func testGetPaymentError() async throws {
        let service = mockService(MockVoltAPIResponder.ErrorForbidden.self)

        await #expect(throws: APIClientError.invalidResponse(.forbidden), performing: {
            _ = try await service.getPayment(paymentId: paymentId, paymentToken: paymentToken)
        })
    }

    @Test("When decoding PaymentResponse payload, then it does not throw any errors")
    func testPaymentResponse() async throws {
        let data1: Data = try ResourceReader.read("PaymentResponse-1", withExtension: "json")
        let data2: Data = try ResourceReader.read("PaymentResponse-2", withExtension: "json")
        let data3: Data = try ResourceReader.read("PaymentResponse-3", withExtension: "json")

        #expect(throws: Never.self, performing: {
            _ = try JSONDecoder().decode(PaymentResponse.self, from: data1)
            _ = try JSONDecoder().decode(PaymentResponse.self, from: data2)
            _ = try JSONDecoder().decode(PaymentResponse.self, from: data3)
        })
    }

    @Test("When cancelPayment endpoint is called, then it doesn't throw and has correct headers and query items")
    func testCancelPaymentEndpoint() async throws {
        let mockInterceptor = MockInterceptor()
        let service = mockService(MockVoltAPIResponder.CancelPayment.self, interceptor: mockInterceptor)

        let expectedHeaders = [.voltAppAuthorizationHeader] + self.expectedHeaders
        let expectedPath = "/payments/\(paymentId)/cancel?"

        await #expect(throws: Never.self, performing: {
            try await service.cancelPayment(paymentId: paymentId, paymentToken: paymentToken)
        })
        let request = try #require(mockInterceptor.interceptedRequest)

        #expect(request.method == .post)
        #expect(request.headerFields.map(\.name).elementsEqual(expectedHeaders))
        #expect(request.path == expectedPath)
    }

    @Test("When cancelPayment fails, then service throws correct error")
    func testCancelPaymentError() async throws {
        let service = mockService(MockVoltAPIResponder.ErrorForbidden.self)

        await #expect(throws: APIClientError.invalidResponse(.forbidden), performing: {
            _ = try await service.cancelPayment(paymentId: paymentId, paymentToken: paymentToken)
        })
    }
}
