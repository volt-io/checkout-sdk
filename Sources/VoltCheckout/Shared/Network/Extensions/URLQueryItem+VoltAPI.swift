//
// URLQueryItem+VoltAPI.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import HTTPTypes

extension URLQueryItem {
    init?(param: String, value: String?) {
        guard let value else { return nil }
        self.init(name: param, value: value)
    }
}
