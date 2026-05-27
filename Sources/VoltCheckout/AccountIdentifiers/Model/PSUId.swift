//
// PSUId.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import SwiftUIValidation

struct PSUId: Equatable, Hashable {
    let id: String

    static let maxLength = 255
    static let helpMessage = "Your ID can contain letters, numbers and @ sign"
    nonisolated(unsafe) static let validationPattern = /^[A-Za-z0-9@]{1,255}$/
}

extension PSUId: RawRepresentable {
    init(rawValue: String) {
        self.init(id: rawValue)
    }

    var rawValue: String {
        id
    }

    var sanitizedValue: String {
        String(rawValue.filter { $0.isLetter || $0.isNumber || $0 == "@" }.prefix(Self.maxLength))
    }
}

extension PSUId: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self = PSUId(rawValue: value)
    }
}

// MARK: - Formatting

extension PSUId {
    struct PSUIdParseStrategy: ParseStrategy {
        func parse(_ value: String) -> PSUId {
            PSUId(rawValue: value)
        }
    }

    struct PSUIdFormatStyle: ParseableFormatStyle {
        var parseStrategy = PSUIdParseStrategy()

        func format(_ value: PSUId) -> String {
            value.rawValue
        }
    }

    func formatted(_ formatStyle: PSUIdFormatStyle) -> String {
        formatStyle.format(self)
    }
}

extension FormatStyle where Self == PSUId.PSUIdFormatStyle {
    static var psuId: Self {
        .init()
    }
}

// MARK: - Validation

extension PSUId {
    struct PSUIdValidationStyle: InputValidationStyle {
        func validatePartial(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .valid
            }
            let rawValue = PSUId(rawValue: value).rawValue

            if rawValue.wholeMatch(of: PSUId.validationPattern) == nil {
                return .invalid(reason: PSUId.helpMessage)
            }
            return .valid
        }

        func validate(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .invalid(reason: PSUId.helpMessage)
            }
            let rawValue = PSUId(rawValue: value).rawValue

            if rawValue.wholeMatch(of: PSUId.validationPattern) == nil {
                return .invalid(reason: PSUId.helpMessage)
            }
            return .valid
        }
    }
}

extension InputValidationStyle where Self == PSUId.PSUIdValidationStyle {
    static var psuId: Self {
        .init()
    }
}
