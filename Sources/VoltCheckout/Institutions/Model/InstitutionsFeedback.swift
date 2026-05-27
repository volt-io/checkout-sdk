//
// InstitutionsFeedback.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct InstitutionsFeedback: FeedbackProvider {
    let context: FeedbackContext = .institutionSelection
    let options: [FeedbackOption] = [
        .bankNotFound,
        .purchaseAbandoned,
        .payAnotherWay,
        .other,
    ]
}
