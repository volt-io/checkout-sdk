//
// VoltCustomer.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 21/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct VoltCustomer {
    var id: String
}

extension DependencyValues {
    var customer: VoltCustomer {
        get { self[VoltCustomer.self] }
        set { self[VoltCustomer.self] = newValue }
    }
}

extension VoltCustomer: DependencyKey {
    static let liveValue = Self(id: {
        preconditionFailure("Live Customer value needs to be configured before being accessed.")
    }())
}

extension VoltCustomer: TestDependencyKey {
    static let testValue = Self(id: "test-customer-id")
    static let previewValue = Self(id: "preview-customer-id")
}
