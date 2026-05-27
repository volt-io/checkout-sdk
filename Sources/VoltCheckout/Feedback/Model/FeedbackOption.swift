//
// FeedbackOption.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

enum FeedbackOption: String {
    case purchaseAbandoned = "I no longer want to make a purchase"
    case payAnotherWay = "I want to pay another way"
    case doNotRememberCredentials = "I don't remember the information required"
    case doNotWantToGiveInformation = "I don't want to provide the information required"
    case bankNotFound = "I can’t find my bank"
    case differentAmount = "Amount is different than I expected"
    case other = "Other"

    var key: String {
        switch self {
        case .purchaseAbandoned:
            "PURCHASE_ABANDONED"
        case .payAnotherWay:
            "PAY_ANOTHER_WAY"
        case .doNotRememberCredentials:
            "DONT_REMEMBER_CREDENTIALS"
        case .doNotWantToGiveInformation:
            "DONT_WANT_GIVE_INFO"
        case .bankNotFound:
            "BANK_NOT_FOUND"
        case .differentAmount:
            "DIFFERENT_AMOUNT"
        case .other:
            "OTHER"
        }
    }
}
