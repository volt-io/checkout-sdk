//
// LoggerInterceptor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes
import OSLog

package struct LoggerInterceptor: RequestInterceptor, ResponseInterceptor {
    package func intercept(_ httpRequest: inout HTTPRequest, with data: inout Data?) {
        log(httpRequest, data)
    }

    package func intercept(
        _ httpRequest: HTTPRequest,
        _ httpResponse: inout HTTPResponse,
        with data: inout Data
    ) {
        log(httpRequest, httpResponse, data)
    }
}

extension LoggerInterceptor {
    private func log(_ request: HTTPRequest, _ data: Data? = nil) {
#if DEBUG
        Logger.http.debug("""
        ↗️ \(request.method) \(request.url?.absoluteString ?? "???")
        Headers: \(request.headerFields.map { "\($0.name): \($0.value)" })
        Content-Length: \(data?.count ?? 0)
        Body: \(data?.prettyPrintedJSONString ?? String(data: data ?? Data(), encoding: .utf8) ?? "nil")
        """)
#endif
    }

    private func log(_ request: HTTPRequest, _ response: HTTPResponse, _ data: Data? = nil) {
#if DEBUG
        Logger.http.debug("""
        ↙️ \(response.status.description) \(request.url?.absoluteString ?? "???")
        Headers: \(response.headerFields.map { "\($0.name): \($0.value)" })
        Content-Length: \(data?.count ?? 0)
        Body: \(data?.prettyPrintedJSONString ?? String(data: data ?? Data(), encoding: .utf8) ?? "nil")
        """)
#endif
    }
}
