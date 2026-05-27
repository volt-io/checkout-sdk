//
// EventTracker+Configuration.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 10/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

extension EventTracker {
    struct Configuration: Sendable {
        let defaultProperties: Event.Properties
        let dynamicProperties: @Sendable () -> Event.Properties
    }
}

extension EventTracker.Configuration {
    static let empty: Self = .init(defaultProperties: [:], dynamicProperties: { [:] })

    // TODO: figure out how to properly deal with hardcoded mixpanel token
    @MainActor
    static func mixpanel(_ customProperties: @autoclosure @escaping @Sendable () -> Event.Properties) -> Self {
        .init(defaultProperties: [
            .distinctId: "$device:\(DeviceInfo.identifier)",
            .deviceId: DeviceInfo.identifier,
            .device: DeviceInfo.model,
            .SDKVersion: VoltCheckout.Version.current.value,
            .integrationType: "mobileiOSSDK",
            .system: DeviceInfo.system,
            .token: "3b61bc80e479d6f1eea1626e17e09b6f",
        ], dynamicProperties: {
            [
                .insertId: UUID().uuidString,
                .timestampInMs: "\(UInt64(Date.now.timeIntervalSince1970 * 1000))",
            ].merging(customProperties()) { $1 }
        })
    }
}
