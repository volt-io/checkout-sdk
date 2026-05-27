//
// CheckoutResult.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 21/04/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

typealias NetworkPaymentStatus = PaymentStatus

/// Result of a checkout flow initiated by `VoltCheckout`.
public enum CheckoutResult: Hashable, Equatable, Codable, Sendable {
    /// User selected an institution. Returned by `VoltCheckout.institution(for:hints:)`.
    case institutionSelected(institution: Institution)

    /// A payment was created and the flow completed. Returned by `VoltCheckout.payment(with:hints:)`.
    case paymentCreated(id: String, status: PaymentStatus, institution: Institution)
}

extension CheckoutResult {
    /// Payment status.
    /// For details about each status see: [Payment status flow](https://docs.volt.io/gateway/payment-status-flow/).
    public enum PaymentStatus: String, Codable, Sendable {
        case newPayment = "NEW_PAYMENT"
        case approvedByRisk = "APPROVED_BY_RISK"
        case refusedByRisk = "REFUSED_BY_RISK"
        case bankRedirect = "BANK_REDIRECT"
        case additionalAuthorizationRequired = "ADDITIONAL_AUTHORIZATION_REQUIRED"
        case authorizedByUser = "AUTHORISED_BY_USER"
        case errorAtBank = "ERROR_AT_BANK"
        case refusedByBank = "REFUSED_BY_BANK"
        case delayedAtBank = "DELAYED_AT_BANK"
        case completed = "COMPLETED"
        case notReceived = "NOT_RECEIVED"
        case received = "RECEIVED"
        case failed = "FAILED"
        case cancelledByUser = "CANCELLED_BY_USER"
        case abandonedByUser = "ABANDONED_BY_USER"
        case awaitingCheckoutAuthorization = "AWAITING_CHECKOUT_AUTHORISATION"
        case accountSelection = "ACCOUNT_SELECTION"
        case requiredRedeem = "REQUIRED_REDEEM"
        case payoutInitiated = "PAYOUT_INITIATED"
        case settled = "SETTLED"
        case unknown = "UNKNOWN"
        case providerCommunicationError = "PROVIDER_COMMUNICATION_ERROR"

        init(_ networkStatus: NetworkPaymentStatus) {
            self = .init(rawValue: networkStatus.rawValue) ?? .unknown
        }
    }
}
