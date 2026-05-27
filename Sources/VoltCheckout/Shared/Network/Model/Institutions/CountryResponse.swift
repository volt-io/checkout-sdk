//
// CountryResponse.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 16/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct CountryResponse: Codable {
    let code: String

    enum CodingKeys: String, CodingKey {
        case code = "country"
    }
}
