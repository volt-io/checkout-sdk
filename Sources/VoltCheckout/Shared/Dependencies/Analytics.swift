//
// Analytics.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 10/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct Analytics {
    var track: @Sendable (_ name: Event.Name, _ properties: Event.Properties) -> Void
}

extension Analytics {
    init(with configuration: EventTracker.Configuration) {
        let tracker = EventTracker(service: AnalyticsService(), configuration: configuration)
        self.init { name, properties in
            tracker.track(name, properties)
        }
    }

    static let noop = Self(
        track: { _, _ in }
    )
}

extension DependencyValues {
    var analytics: Analytics {
        get { self[Analytics.self] }
        set { self[Analytics.self] = newValue }
    }
}

extension Analytics: DependencyKey {
    static var liveValue: Self {
        preconditionFailure("Live value of the Analytics needs to be configured before being accessed.")
    }
}

extension Analytics: TestDependencyKey {
    static let previewValue = Self.noop
    static let testValue = Self(with: .empty)
}
