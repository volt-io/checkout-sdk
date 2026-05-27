//
// HeadersInjectorInterceptor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes

package struct HeadersInjectorInterceptor: RequestInterceptor {
    package let headers: HTTPFields

    package init(headers: HTTPFields) {
        self.headers = headers
    }

    package func intercept(_ httpRequest: inout HTTPTypes.HTTPRequest) {
        var data: Data?
        intercept(&httpRequest, with: &data)
    }

    @_disfavoredOverload
    package func intercept(_ httpRequest: inout HTTPTypes.HTTPRequest, with _: inout Data?) {
        httpRequest.headerFields += headers
    }
}
