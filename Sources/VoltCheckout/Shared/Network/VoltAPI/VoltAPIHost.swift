//
// VoltAPIHost.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
public import HTTPNetworking

/// Protocol that lets parametrize `VoltAPIService` with custom `HTTPHost` implementation.
public protocol VoltAPIHost: HTTPHost {}

/// Volt API production host.
public struct VoltAPIProductionHost: VoltAPIHost {
    public static let authority = "gateway.volt.io"

    public init() {}
}

/// Volt API sandbox host. Use this host to test your integration. When using sandbox host no real money change hands.
public struct VoltAPISandboxHost: VoltAPIHost {
    public static let authority = "gateway.sandbox.volt.io"

    public init() {}
}
