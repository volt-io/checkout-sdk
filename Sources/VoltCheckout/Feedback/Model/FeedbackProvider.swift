//
// FeedbackProvider.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

protocol FeedbackProvider: Sendable {
    var context: FeedbackContext { get }
    var options: [FeedbackOption] { get }
}

struct AnyFeedbackProvider: FeedbackProvider {
    private let provider: FeedbackProvider

    init(_ provider: FeedbackProvider) {
        self.provider = provider
    }

    var context: FeedbackContext {
        provider.context
    }

    var options: [FeedbackOption] {
        provider.options
    }
}

extension AnyFeedbackProvider: Equatable {
    static func == (lhs: AnyFeedbackProvider, rhs: AnyFeedbackProvider) -> Bool {
        lhs.context == rhs.context && lhs.options == rhs.options
    }
}
