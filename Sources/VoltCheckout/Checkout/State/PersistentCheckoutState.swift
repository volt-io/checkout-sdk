//
// PersistentCheckoutState.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 09/05/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct PersistentCheckoutState: Equatable, Codable {
    enum Flow: Equatable, Codable {
        case institution(Currency, CheckoutHints)
        case payment(PaymentIntent, CheckoutHints, Institution?, PaymentIdentifier?)
    }

    var flow: Flow
    var skipEducational: Bool
}

extension PersistentCheckoutState {
    init?(with flowState: CheckoutRootFeature.Flow.State?, skipEducational: Bool = false) {
        switch flowState {
        case .institution(let state):
            self.flow = .institution(state.currency, state.hints)
            self.skipEducational = skipEducational || state.path.contains { $0.is(\.educational) }
        case .payment(let state):
            self.flow = .payment(state.intent, state.hints, state.selectedInstitution, state.paymentIdentifier)
            self.skipEducational = skipEducational || state.path.contains { $0.is(\.educational) }
        case .none:
            return nil
        }
    }
}
