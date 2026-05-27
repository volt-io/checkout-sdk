//
// PaymentStatus.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

enum PaymentStatus: String, Codable {
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
}
