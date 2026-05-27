//
// VoltCheckoutTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 24/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import VoltCheckout

@Suite("VoltCheckout Tests")
@MainActor struct VoltCheckoutTests {
    let customerId = "123"
    let config = VoltCheckout.Configuration.sandbox(customerId: "123") { "auth-token" }

    @Test("When initializing VoltCheckout, then root store is correctly set up")
    func testInitRootStore() async throws {
        let voltSDK = VoltCheckout(configuration: config)

        #expect(voltSDK.store.state == .init())
    }

    // TODO: figure out how to test VoltCheckout public methods
}
