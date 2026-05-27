//
// HTTPEndpoint.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 16/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

/// A structure that defines a HTTP endpoint.
///
/// An endpoint is specialized by the `HTTPHost` that it points to.
/// Other defining aspects are expressed by the properties.
package struct HTTPEndpoint<Host: HTTPHost>: Sendable {
    /// The HTTP request method under which endpoint is available.
    package var method: HTTPRequest.Method
    /// A URL path component which identifies the endpoint. Path has to start with `/`.
    package var path: String
    /// Headers that should be used with the request to this endpoint.
    package var headers: HTTPFields = [:]
    /// An array of URL query items added to the URL.
    package var query: [URLQueryItem] = []
    /// Request body data.
    package var body: Data?

    package init(method: HTTPRequest.Method,
                 path: String,
                 headers: HTTPFields = [:],
                 query: [URLQueryItem] = [],
                 body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.headers = headers
        self.query = query
        self.body = body
    }
}

extension HTTPEndpoint {
    /// Complete `URL` for the endpoint created from all the components.
    /// - Throws: `URLError.badURL`
    package var url: URL {
        get throws {
            var url = try Host.url
            url.append(path: path)
            url.append(queryItems: query)
            return url
        }
    }

    /// `HTTPRequest` configured using endpoint properties.
    /// - Throws: `URLError.badURL`.
    package var request: HTTPRequest {
        get throws {
            .init(method: method, url: try url, headerFields: headers)
        }
    }
    
    /// Convenience method that combines endpoint properties with passed values and returns new endpoint.
    /// - Parameters:
    ///   - headers: Headers to be added to the endpoint.
    ///   - query: Query items to be added to the endpoint.
    ///   - body: Body data to be added to the endpoint.
    /// - Returns: New endpoint.
    package func with(
        headers: HTTPFields? = nil,
        query: [URLQueryItem]? = nil,
        body: Data? = nil
    ) -> Self {
        .init(
            method: self.method,
            path: self.path,
            headers: headers ?? self.headers,
            query: query ?? self.query,
            body: body ?? self.body
        )
    }
    
    /// Convenience method that combines endpoint properties with passed values and returns new endpoint.
    /// - Parameters:
    ///   - headers: Headers to be added to the endpoint.
    ///   - query: Query items to be added to the endpoint.
    ///   - body: A `Codable` value to be encoded as endpoint body data.
    /// - Returns: New endpoint.
    /// - Throws: Encoding errors.
    package func with<T>(
        headers: HTTPFields? = nil,
        query: [URLQueryItem]? = nil,
        body: T? = nil
    ) throws -> Self where T: Codable {
        let data = (body != nil) ? try JSONEncoder().encode(body) : self.body
        return with(headers: headers, query: query, body: data)
    }
}
