//
// EducationalFeedback.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct EducationalFeedback: FeedbackProvider {
    let context: FeedbackContext = .educational
    let options: [FeedbackOption] = [
        .purchaseAbandoned,
        .payAnotherWay,
        .other,
    ]
}
