//
// APIClientTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
@testable import HTTPNetworking

@Suite("APIClient Tests")
struct APIClientTests {

    @Test("When calling JSON returning endpoint, then response should be correctly decoded")
    func testJSONResponse() async throws {
        let session = URLSession(mockResponder: MockDataResponse.MockDataURLResponder.self)
        let client = APIClient(session: session)

        let response = try await client.request(MockDataResponse.self, from: .getExample)
        #expect(response == MockDataResponse.testResponse)
    }

    @Test("When calling Data returning endpoint, then response data should be returned")
    func testDataResponse() async throws {
        let session = URLSession(mockResponder: MockDataResponse.MockDataURLResponder.self)
        let client = APIClient(session: session)

        let response = try await client.request(.getData)
        #expect(response == MockDataResponse.correctData)
    }

    @Test("When request results in network error, then correct client error should be thrown")
    func testNetworkError() async throws {
        let session = URLSession(mockResponder: MockNetworkErrorResponder.self)
        let client = APIClient(session: session)

        await #expect(throws: APIClientError.transportError(URLError(.timedOut)), performing: {
            try await client.request(.getData)
        })
    }

    @Test("When request results in unsuccessful status code, then correct client error should be thrown")
    func testClientError() async throws {
        let session = URLSession(mockResponder: MockClientErrorResponder.self)
        let client = APIClient(session: session)

        await #expect(throws: APIClientError.invalidResponse(.forbidden), performing: {
            try await client.request(.getData)
        })
    }

    @Test("When request results in server error, then correct client error should be thrown")
    func testServerError() async throws {
        let session = URLSession(mockResponder: MockServerErrorResponder.self)
        let client = APIClient(session: session)

        await #expect(throws: APIClientError.invalidResponse(.serviceUnavailable), performing: {
            try await client.request(.getData)
        })
    }

    @Test("When request returns malformed data, then decoding error should be thrown")
    func testDecodingError() async throws {
        let session = URLSession(mockResponder: MockDataResponse.MockMalformedDataURLResponder.self)
        let client = APIClient(session: session)

        await #expect(throws: DecodingError.self, performing: {
            try await client.request(MockDataResponse.self, from: .getData)
        })
    }

    @Test("When request and response interceptor is added, then it should be correctly invoked")
    func testRequestAndResponseInterception() async throws {
        let session = URLSession(mockResponder: MockDataResponse.MockDataURLResponder.self)
        let mockInterceptor = MockInterceptor()
        let client = APIClient(
            requestInterceptors: [mockInterceptor],
            responseInterceptors: [mockInterceptor],
            session: session
        )

        try await client.request(.getExample)

        #expect(mockInterceptor.interceptedRequest != nil)
        #expect(mockInterceptor.interceptedResponse != nil)
    }
}
