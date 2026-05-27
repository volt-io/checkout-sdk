//
// LogReader.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import OSLog

package struct LogReader {
    private let subsystem: String
    private let category: String
    private let logStore: OSLogStore

    package var logs: [OSLogEntryLog] {
        get throws {
            try logStore
                .getEntries()
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == subsystem && $0.category == category }
        }
    }

    package init(subsystem: String, category: String) throws {
        self.subsystem = subsystem
        self.category = category
        self.logStore = try OSLogStore(scope: .currentProcessIdentifier)
    }
}
