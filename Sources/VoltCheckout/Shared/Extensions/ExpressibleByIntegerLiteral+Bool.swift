//
// ExpressibleByIntegerLiteral+Bool.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 27/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

extension ExpressibleByIntegerLiteral {
    init(_ booleanLiteral: BooleanLiteralType) {
        self = booleanLiteral ? 1 : 0
    }
}
