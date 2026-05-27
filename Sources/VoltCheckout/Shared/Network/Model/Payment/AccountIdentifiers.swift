//
// AccountIdentifiers.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct AccountIdentifiers: Codable {
    var iban: String?
    var psuId: String?
    var branchCode: String?
    var accountNumber: String?
}
