//
// CheckoutRoutingUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct CheckoutRoutingUseCase {
    var institutionFlowPath: @Sendable (
        _ currency: Currency,
        _ hints: CheckoutHints,
        _ skipEducational: Bool
    ) -> [InstitutionFlowFeature.Path.State] = { _, _, _ in [] }

    var paymentFlowPath: @Sendable (
        _ intent: PaymentIntent,
        _ hints: CheckoutHints,
        _ skipEducational: Bool
    ) -> [PaymentFlowFeature.Path.State] = { _, _, _ in [] }

    var resumedPaymentFlowPath: @Sendable (
        _ intent: PaymentIntent,
        _ institution: Institution,
        _ identifier: PaymentIdentifier?
    ) -> [PaymentFlowFeature.Path.State] = { _, _, _ in [] }
}

extension CheckoutRoutingUseCase: DependencyKey {
    static let liveValue = Self { currency, hints, skipEducational in
        switch (skipEducational, hints) {
        case (true, .none):
            [.institutions(.init(currency: currency, defaultCountry: nil))]
        case (true, .useDefaultCountry(let country)):
            [.institutions(.init(currency: currency, defaultCountry: country))]
        default:
            [.educational(.init())]
        }
    } paymentFlowPath: { intent, hints, skipEducational in
        switch (skipEducational, hints) {
        case (true, .none):
            [.institutions(.init(currency: intent.amount.currency, defaultCountry: nil))]
        case (true, .useDefaultCountry(let country)):
            [.institutions(.init(currency: intent.amount.currency, defaultCountry: country))]
        case (_, .useInstitution(let institution)):
            [
                .institutions(.init(currency: intent.amount.currency, defaultCountry: institution.country)),
                .payment(.init(intent: intent, institution: institution)),
            ]
        default:
            [.educational(.init())]
        }
    } resumedPaymentFlowPath: { intent, institution, identifier in
        [
            .institutions(.init(
                currency: intent.amount.currency,
                defaultCountry: institution.country,
                selectedCountry: institution.country
            )),
            .payment(.init(intent: intent, institution: institution, identifier: identifier)),
        ]
    }
}

extension DependencyValues {
    var checkoutRouting: CheckoutRoutingUseCase {
        get { self[CheckoutRoutingUseCase.self] }
        set { self[CheckoutRoutingUseCase.self] = newValue }
    }
}

extension CheckoutRoutingUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
