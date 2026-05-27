//
// EventTracker.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 08/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Dependencies
import Foundation

struct EventTracker {
    let service: AnalyticsService
    let configuration: Configuration

    @Dependency(\.logger[subsystem: VoltCheckout.identifier, category: "Analytics"]) private var logger

    var combinedProperties: Event.Properties {
        configuration.defaultProperties
            .merging(configuration.dynamicProperties()) { $1 }
    }

    func track(_ name: Event.Name, _ properties: Event.Properties) {
        let eventProperties = combinedProperties.merging(properties) { $1 }
        let event = Event(name: name, properties: eventProperties)
#if DEBUG
        log(event)
#endif
#if ENABLE_ANALYTICS
        Task {
            do {
                try await service.send(event)
            } catch {
                log(event, error)
            }
        }
#endif
    }

    private func log(_ event: Event, _ error: Error? = nil) {
        logger.debug("""
        📊 \(event.name.rawValue)
        Properties: \(event.properties.map { "\($0.key): \($0.value ?? "nil")" })
        """)
        if let error {
            logger.error("Error: \(error)")
        }
    }
}
