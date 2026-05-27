//
// PaymentType.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

enum PaymentType: String, Codable {
    case bill = "BILL"
    case goods = "GOODS"
    case personToPerson = "PERSON_TO_PERSON"
    case services = "SERVICES"
    case other = "OTHER"
}
