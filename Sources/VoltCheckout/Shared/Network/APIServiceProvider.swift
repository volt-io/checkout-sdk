//
// APIServiceProvider.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPNetworking

protocol APIServiceProvider: Sendable {
    var client: APIClient { get }
    
    init(requestInterceptors: [RequestInterceptor], responseInterceptors: [ResponseInterceptor], session: URLSession)
}
