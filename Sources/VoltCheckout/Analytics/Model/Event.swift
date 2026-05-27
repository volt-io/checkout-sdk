//
// Event.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 28/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct Event: Codable {
    let name: Name
    let properties: Properties

    enum CodingKeys: String, CodingKey {
        case name = "event",
             properties
    }
}

extension Event {
    typealias Properties = [Property: String?]

    /// The value sent as an event name
    enum Name: String, Codable {
        case openBankingPage = "Open banking page visit",
             openTermsAndConditions = "Terms and conditions",
             continueOnWelcomeView = "Continue on the Welcome screen click",
             bankSearch = "Bank name searched",
             bankSelection = "Bank select",
             bankChange = "Bank change click",
             bankNotFound = "Bank not found submitted",
             bankSuggestion = "Still can't find your bank? Let us know click",
             checkoutIsLoading = "Checkout is loading",
             beginPayment = "Pay at my bank click",
             redeemPayment = "Payment redeem called",
             cancellation = "Cancel click",
             cancellationConfirmed = "Cancellation confirmed",

             placeholderEvent = "" // TODO: remove when we finalize events configuration
    }
    
    /// Property names available to track with the event
    enum Property: String, Codable, CaseIterable, CodingKeyRepresentable {
        case customerId,
             paymentId,
             countryId,
             checkoutStatus,
             bankId,
             bankName,
             bankNameNotFound,
             searchedQueries,
             cancelledScreen,
             feedback,
             insertId = "$insert_id",
             distinctId = "distinct_id",
             deviceId = "$device_id",
             device,
             SDKVersion,
             integrationType,
             system = "$os",
             timestampInMs = "time",
             token
    }
}
