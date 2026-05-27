//
// PaymentIdentifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 28/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct PaymentIdentifier: Identifiable, Equatable, Codable {
    let id: String
    let token: String
    var status: PaymentStatus
}

extension PaymentIdentifier {
    init(response: PaymentResponse) throws(PaymentError) {
        guard let token = response.paymentInitiationFlow.details.token else {
            throw PaymentError.tokenNotFound
        }

        self.id = response.id
        self.token = token
        self.status = response.status
    }
}
