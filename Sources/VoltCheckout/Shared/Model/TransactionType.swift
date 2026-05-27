//
// TransactionType.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 22/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// Type of the transaction.
public enum TransactionType: Codable, Sendable {
    case bill
    case goods
    case services
    case other
}
