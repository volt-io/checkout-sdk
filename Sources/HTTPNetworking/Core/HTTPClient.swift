//
// HTTPClient.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 17/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

/// A protocol that defines HTTP client that performs network requests.
///
/// `HTTPClient` protocol provides methods for sending requests to endpoints
/// that return no data, raw data, or structured data. It allows to use custom decoders
/// for structured responses that conform to `Decodable`. All methods are asynchronous.
///
/// - Note: Conforming types have to be `Sendable`.
package protocol HTTPClient: Sendable {
    /// A `URLSession` object used by the client to transfer data.
    var session: URLSession { get async }
    
    /// An array of request interceptors that will modify the request before it is sent.
    var requestInterceptors: [any RequestInterceptor] { get async }

    /// An array of response interceptors that will modify the response before it is returned.
    var responseInterceptors: [any ResponseInterceptor] { get async }

    /// Performs a request to the given endpoint, allowing to pass custom response decoder and request id.
    /// - Parameters:
    ///   - endpoint: An endpoint to which the request will be sent.
    ///   - decoder: A custom decoder used to decode the response data.
    ///   - id: Custom id used by the client to identify the request.
    /// - Returns: An instance of `Response`, decoded using `decoder`.
    /// - Throws: Networking and decoding errors.
    func request<Host, Decoder, Response>(
        _ endpoint: HTTPEndpoint<Host>,
        decoder: Decoder,
        id: UUID
    ) async throws -> Response where Host: HTTPHost, Decoder: PayloadDecoder, Response: Decodable & Sendable
    
    /// Performs a request to the given endpoint, allowing to pass custom request id.
    /// - Parameters:
    ///   - endpoint: A data returning endpoint to which the request will be sent.
    ///   - id: Custom id used by the client to identify the request.
    /// - Returns: Raw response data, or `nil`. Returned result is discardable.
    /// - Throws: Networking errors.
    @discardableResult
    func request<Host>(
        _ endpoint: HTTPEndpoint<Host>,
        id: UUID
    ) async throws -> Data? where Host: HTTPHost
    
    /// Cancels the request for given identifier. This function does nothing if it can't find the request.
    /// - Parameter id: Request identifier.
    func cancelRequest(with id: UUID) async

    /// Cancels all active requests.
    func cancelAllRequests() async
}

extension HTTPClient {
    /// Performs a request to the given endpoint, allowing to pass custom response decoder.
    /// - Parameters:
    ///   - endpoint: An endpoint to which the request will be sent.
    ///   - decoder: A custom decoder used to decode the response data.
    /// - Returns: An instance of `Response`, decoded using `decoder`.
    /// - Throws: Networking and decoding errors.
    package func request<Host, Decoder, Response>(
        _ endpoint: HTTPEndpoint<Host>,
        decoder: Decoder
    ) async throws -> Response where Host: HTTPHost, Decoder: PayloadDecoder, Response: Decodable & Sendable {
        try await request(endpoint, decoder: decoder, id: UUID())
    }
    
    /// Request JSON decoded to given response type from particular endpoint.
    /// - Parameters:
    ///   - response: A type of the response to decode to.
    ///   - endpoint: An endpoint to which the request will be sent.
    /// - Returns: An instance of `Response`, decoded from JSON.
    /// - Throws: Networking and decoding errors.
    package func request<Host, Response>(
        _: Response.Type,
        from endpoint: HTTPEndpoint<Host>
    ) async throws -> Response where Host: HTTPHost, Response: Decodable & Sendable {
        try await request(endpoint, decoder: JSONDecoder())
    }

    /// Performs a request to the given endpoint.
    /// - Parameter endpoint: An endpoint to which the request will be sent.
    /// - Returns: Raw response `Data`, or `nil`. Returned result is discardable.
    /// - Throws: Networking errors.
    @discardableResult
    package func request<Host>(
        _ endpoint: HTTPEndpoint<Host>
    ) async throws -> Data? where Host: HTTPHost {
        try await request(endpoint, id: UUID())
    }
}
