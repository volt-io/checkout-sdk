//
// MockPaymentRequest.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 17/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

@testable import VoltCheckout

extension PaymentRequest {
    static let testValue = Self(
        currency: "EUR",
        amount: 1000,
        payer: Payer(reference: "payer@example.com"),
        device: Device(ip: "1.1.1.1"),
        paymentSystem: .openBankingEU,
        openBankingEU: OpenBankingRequest(type: .services, accountIdentifiers: AccountIdentifiers()),
        openBankingUK: OpenBankingRequest(type: .goods, accountIdentifiers: AccountIdentifiers())
    )
}
