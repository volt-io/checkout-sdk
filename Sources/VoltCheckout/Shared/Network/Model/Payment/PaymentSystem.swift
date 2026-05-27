//
// PaymentSystem.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

enum PaymentSystem: String, Codable {
    case openBankingUK = "OPEN_BANKING_UK"
    case openBankingEU = "OPEN_BANKING_EU"
    case nppPayToAU = "NPP_PAY_TO_AU"
}
