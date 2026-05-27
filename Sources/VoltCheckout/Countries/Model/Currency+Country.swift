//
// Currency+Country.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

extension Currency {
    var country: Country? {
        switch self {
        case .AUD:
            Country(.australia)
        case .GBP:
            Country(.unitedKingdom)
        case .NOK:
            Country(.norway)
        case .PLN:
            Country(.poland)
        case .RON:
            Country(.romania)
        case .SEK:
            Country(.sweden)
        case .EUR:
            nil
        }
    }
}
