//
// AccountIdentifiersFeedback.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct AccountIdentifiersFeedback: FeedbackProvider {
    let context: FeedbackContext = .accountIdentifiers
    let options: [FeedbackOption] = [
        .purchaseAbandoned,
        .doNotRememberCredentials,
        .doNotWantToGiveInformation,
        .other,
    ]
}
