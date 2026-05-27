//
// Logger+HTTPNetworking.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import OSLog

extension Logger {
    internal static let http = Logger(subsystem: "io.volt", category: "HTTPNetworking")
}
