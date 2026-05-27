//
// APIClient.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

/// An actor representing an API client.
///
/// It implements `HTTPClient` protocol and manage execution of a set of requests.
package actor APIClient: HTTPClient {
    private typealias RequestTask<Response: Sendable> = Task<Response, Error>

    package let session: URLSession

    package var requestInterceptors: [any RequestInterceptor]

    package var responseInterceptors: [any ResponseInterceptor]

    private var requests: [UUID: any Sendable] = [:]

    private var logger: LoggerInterceptor

    /// Client initializer, allows to pass custom `URLSession` that will be used to perform all requests.
    /// - Parameters:
    ///   - requestInterceptors: Request interceptors that will modify each request before it's sent.
    ///   - responseInterceptors: Response interceptors that will modify each response before it's returned.
    ///   - session: Custom `URLSession` that will be used to send client requests.
    /// - Note: Interceptors are applied to requests and responses in the order they appear in their arrays.
    package init(
        requestInterceptors: [any RequestInterceptor] = [],
        responseInterceptors: [any ResponseInterceptor] = [],
        session: URLSession = .shared
    ) {
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
        self.session = session
        self.logger = LoggerInterceptor()

        self.requestInterceptors.append(self.logger)
        self.responseInterceptors.append(self.logger)
    }
}

extension APIClient {
    package func request<Host, Decoder, Response>(
        _ endpoint: HTTPEndpoint<Host>,
        decoder: Decoder,
        id: UUID
    ) async throws -> Response where Host: HTTPHost, Decoder: PayloadDecoder, Response: Decodable & Sendable {
        guard requests[id] == nil else {
            throw APIClientError.duplicateRequestId
        }

        let task = RequestTask {
            try Task.checkCancellation()
            let data = try await performRequest(endpoint.request, with: endpoint.body)
            try Task.checkCancellation()
            return try decoder.decode(Response.self, from: data)
        }

        requests[id] = task
        defer { requests.removeValue(forKey: id) }

        return try await task.value
    }

    package func request<Host>(
        _ endpoint: HTTPEndpoint<Host>,
        id: UUID
    ) async throws -> Data? {
        guard requests[id] == nil else {
            throw APIClientError.duplicateRequestId
        }

        let task = RequestTask {
            try Task.checkCancellation()
            return try await performRequest(endpoint.request, with: endpoint.body)
        }

        requests[id] = task
        defer { requests.removeValue(forKey: id) }

        return try await task.value
    }

    package func cancelRequest(with id: UUID) {
        guard let task = requests[id] as? RequestTask<Sendable> else {
            return
        }
        task.cancel()
        requests.removeValue(forKey: id)
    }

    package func cancelAllRequests() {
        requests.forEach { _, task in
            (task as? RequestTask<Sendable>)?.cancel()
        }
        requests.removeAll()
    }
}

extension APIClient {
    /// Executes given HTTP request.
    /// - Parameter httpRequest: Request to be performed.
    /// - Parameter bodyData: Data of the body to be sent with the request.
    /// - Returns: Response data.
    /// - Throws: `APIClientError`
    private func performRequest(_ httpRequest: HTTPRequest, with bodyData: Data? = nil) async throws -> Data {
        do {
            var request = httpRequest
            var requestBody = bodyData

            for interceptor in requestInterceptors {
                try await interceptor.intercept(&request, with: &requestBody)
            }

            var (data, response): (Data, HTTPResponse)
            if let requestBody {
                (data, response) = try await session.upload(for: request, from: requestBody)
            } else {
                (data, response) = try await session.data(for: request)
            }

            for interceptor in responseInterceptors {
                try await interceptor.intercept(request, &response, with: &data)
            }

            guard response.status.kind == .successful else {
                throw APIClientError.invalidResponse(response.status)
            }
            return data
        } catch APIClientError.interceptorError(let error) {
            throw error
        } catch let error as APIClientError {
            throw error
        } catch {
            throw APIClientError.transportError(error)
        }
    }
}
