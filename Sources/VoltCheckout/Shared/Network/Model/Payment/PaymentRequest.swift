//
// PaymentRequest.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct PaymentRequest: Codable {
    let currency: String
    let amount: UInt
    var paymentReference: String?
    var internalReference: String?
    let payer: Payer
    let device: Device
    let paymentSystem: PaymentSystem
    let openBankingEU: OpenBankingRequest?
    let openBankingUK: OpenBankingRequest?
}

extension PaymentRequest {
    struct Payer: Codable {
        let reference: String
        var firstName: String?
        var lastName: String?
        var organizationName: String?
        var email: String?
        var phoneNumber: String?
    }

    struct Device: Codable {
        let ip: String
        var userAgent: String?
    }

    struct OpenBankingRequest: Codable {
        let type: PaymentType
        var institutionId: String?
        var validityPeriod: UInt?
        let accountIdentifiers: AccountIdentifiers
        var redirectType: String?
    }
}
