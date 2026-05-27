//
// PaymentFeedback.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct PaymentFeedback: FeedbackProvider {
    let context: FeedbackContext = .paymentProgress
    let options: [FeedbackOption] = [
        .purchaseAbandoned,
        .payAnotherWay,
        .differentAmount,
        .other,
    ]
}
