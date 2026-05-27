//
// VoltAPIHeaders.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import HTTPTypes

// swiftlint:disable force_unwrapping
extension HTTPField.Name {
    static let idempotencyKeyHeader = Self("Idempotency-Key")!
    static let voltApiVersionHeader = Self("X-Volt-Api-Version")!
    static let voltInitiationChannelHeader = Self("X-Volt-Initiation-Channel")!
    static let voltAppAuthorizationHeader = Self("X-Volt-App-Authorization")!
    static let voltApp = Self("X-Volt-App")!
}
// swiftlint:enable force_unwrapping
