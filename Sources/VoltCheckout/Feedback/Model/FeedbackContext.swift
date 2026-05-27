//
// FeedbackContext.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

enum FeedbackContext: String {
    case accountSelection = "ACCOUNT_SELECTION_VIEW"
    case accountIdentifiers = "ADDITIONAL_REQUIREMENTS_VIEW"
    case institutionSelection = "BANK_SELECTION_VIEW"
    case institutionNotFound = "INSTITUTION_NOT_FOUND_VIEW" // TODO: should we support?
    case institutionsError = "INSTITUTIONS_ERROR_VIEW"      // TODO: should we support?
    case countrySelection = "COUNTRY_SELECTION_VIEW"        // TODO: should we support?
    case educational = "EDUCATIONAL_VIEW"
    case paymentProgress = "PAYMENT_PROGRESS_VIEW"          // TODO: not in hosted
    case summary = "SUMMARY_VIEW"                           // TODO: not in SDK
    case redirect = "REDIRECT_VIEW"                         // TODO: not in SDK
}
