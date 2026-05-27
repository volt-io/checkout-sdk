//
// PaymentError.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

enum PaymentError: Error {
    case tokenNotFound,
         maxRetriesReached,
         institutionNotActive,
         missingAccountIdentifiers,
         failed(PaymentStatus),
         unknown(Error?)
}

extension PaymentError: Equatable {
    static func == (lhs: PaymentError, rhs: PaymentError) -> Bool {
        switch (lhs, rhs) {
        case let (.unknown(lhsError), .unknown(rhsError)):
            lhsError?.localizedDescription == rhsError?.localizedDescription
        case let (.failed(lhsStatus), .failed(rhsStatus)):
            lhsStatus == rhsStatus
        case (.tokenNotFound, .tokenNotFound),
             (.maxRetriesReached, .maxRetriesReached),
             (.institutionNotActive, .institutionNotActive),
             (.missingAccountIdentifiers, .missingAccountIdentifiers):
            true
        default:
            false
        }
    }
}
