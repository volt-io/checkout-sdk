//
// VoltCheckout.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 28/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation
import OSLog
import VoltDesignSystem

/// VoltCheckout SDK
@preconcurrency @MainActor
public final class VoltCheckout {
    /// Current version of the SDK package.
    nonisolated public static let version: Version = .current

    /// An organization identifier used internally by the package.
    nonisolated public static let identifier = "io.volt"

    let store: StoreOf<CheckoutRootFeature>

    @Dependency(\.checkoutResult) var checkoutResult

    /// Initialize the VoltCheckout SDK.
    /// - Parameter configuration: Custom SDK configuration.
    public init<Host>(configuration: Configuration<Host>) where Host: VoltAPIHost {
        VoltFont.registerCustomFonts()

        self.store = Store(initialState: .init()) {
            CheckoutRootFeature()
        } withDependencies: {
            guard $0.context == .live else { return }

            $0.customer = .init(id: configuration.customerId)
            $0.analytics = .init(with: .mixpanel([.customerId: configuration.customerId]))
            $0.voltAPI = .init(with: VoltAPIService<Host>(authTokenProvider: configuration.tokenProvider))
        }
    }
    
    /// Begin institution selection flow for given currency, and optional country.
    /// This method awaits while user is selecting institution, and returns
    /// only after user selected institution or canceled the flow.
    /// - Parameters:
    ///   - currency: Currency for which supporting institutions will be presented.
    ///   - hints: Hints that allow to adjust institution selection flow.
    /// - Returns: `CheckoutResult.institutionSelected`, or `nil` if user abandoned the flow.
    @discardableResult
    public func institution(for currency: Currency, hints: CheckoutHints = .none) async -> CheckoutResult? {
        let resultTask = checkoutResult.resultTask()
        let storeTask = store.send(.delegate(.onBeginInstitutionFlow(currency, hints)))

        await storeTask.finish()
        return await resultTask.value
    }

    /// Begin payment initiation with provided payment intent and hints about the flow.
    /// - Parameters:
    ///   - intent: Details used to initiate a payment.
    ///   - hints: Hints that allow to adjust payment flow.
    /// - Returns: `CheckoutResult.paymentCreated`, or `nil` if user abandoned the flow before payment was created.
    @discardableResult
    public func payment(with intent: PaymentIntent, hints: CheckoutHints = .none) async -> CheckoutResult? {
        let resultTask = checkoutResult.resultTask()
        let storeTask = store.send(.delegate(.onBeginPaymentFlow(intent, hints)))

        await storeTask.finish()
        return await resultTask.value
    }
}
