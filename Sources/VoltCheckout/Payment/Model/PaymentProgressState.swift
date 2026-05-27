//
// PaymentProgressState.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation
import VoltDesignSystem

@CasePathable
enum PaymentProgressState: Equatable {
    case verifying,
         collectingAccountIdentifiers,
         processing(provider: String?),
         awaitingRedirect(url: URL),
         succeeded,
         delayed,
         failed(error: PaymentError)
}

extension PaymentProgressState {
    var viewState: VoltStatusProgressState {
        switch self {
        case .succeeded:
            .success
        case .delayed:
            .pending
        case .failed:
            .failure
        default:
            .processing
        }
    }

    var title: String {
        switch self {
        case .succeeded:
            "Payment success!"
        case .delayed:
            "Transaction pending"
        case .failed:
            "Payment failed"
        default:
            "Processing transaction..."
        }
    }

    var description: String {
        switch self {
        case .processing(.some(let provider)):
            "Please wait, processed with \(provider)."
        case .awaitingRedirect:
            "Please wait, redirecting to your bank."
        case .succeeded:
            "Woohoo, your payment has been successful."
        case .delayed:
            "Your transaction is still being processed."
        case .failed:
            "Oops, it appears there's an issue. No funds have moved from your account."
        default:
            "Please wait, connecting to your bank."
        }
    }
}
