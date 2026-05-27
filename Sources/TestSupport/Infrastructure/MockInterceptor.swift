//
// MockInterceptor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking
import HTTPTypes

package final class MockInterceptor: RequestInterceptor, ResponseInterceptor {
    nonisolated(unsafe) package private(set) var interceptedRequest: HTTPRequest?
    nonisolated(unsafe) package private(set) var interceptedRequestBody: Data?
    nonisolated(unsafe) package private(set) var interceptedResponse: HTTPResponse?
    nonisolated(unsafe) package private(set) var interceptedResponseBody: Data?

    package init() {}

    package func intercept(_ httpRequest: inout HTTPRequest, with data: inout Data?) {
        interceptedRequest = httpRequest
        interceptedRequestBody = data
    }
    
    package func intercept(_: HTTPRequest, _ httpResponse: inout HTTPResponse, with data: inout Data) {
        interceptedResponse = httpResponse
        interceptedResponseBody = data
    }
}
