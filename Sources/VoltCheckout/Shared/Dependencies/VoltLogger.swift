//
// VoltLogger.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 10/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation
import OSLog

// swiftlint:disable redundant_type_annotation
@DependencyClient
struct VoltLogger {
    var logger: Logger = Logger()
}
// swiftlint:enable redundant_type_annotation

extension DependencyValues {
    var logger: Logger {
        get { self[VoltLogger.self].logger }
        set { self[VoltLogger.self].logger = newValue }
    }
}

extension VoltLogger: DependencyKey {
    public static let liveValue = Self()
    public static let testValue = Self()
    public static let previewValue = Self()
}

extension Logger {
    subscript(subsystem subsystem: String, category category: String) -> Self {
        Logger(subsystem: subsystem, category: category)
    }
}
