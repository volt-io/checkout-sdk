//
// BranchCode.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import SwiftUIValidation

struct BranchCode: Equatable, Hashable {
    let code: String

    static let maxLength = 3
    static let prompt = "123"
    static let helpMessage = "3 digit number"
    nonisolated(unsafe) static let validationPattern = /^[0-9]{3}$/
}

extension BranchCode: RawRepresentable {
    init(rawValue: String) {
        self.init(code: rawValue)
    }

    var rawValue: String {
        code
    }

    var sanitizedValue: String {
        String(rawValue.filter(\.isNumber).prefix(Self.maxLength))
    }
}

extension BranchCode: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self = BranchCode(rawValue: value)
    }
}

// MARK: - Formatting

extension BranchCode {
    struct BranchCodeParseStrategy: ParseStrategy {
        func parse(_ value: String) -> BranchCode {
            BranchCode(rawValue: value)
        }
    }

    struct BranchCodeFormatStyle: ParseableFormatStyle {
        var parseStrategy = BranchCodeParseStrategy()

        func format(_ value: BranchCode) -> String {
            value.rawValue
        }
    }

    func formatted(_ formatStyle: BranchCodeFormatStyle) -> String {
        formatStyle.format(self)
    }
}

extension ParseableFormatStyle where Self == BranchCode.BranchCodeFormatStyle {
    static var branchCode: Self {
        .init()
    }
}

// MARK: - Validation

extension BranchCode {
    struct BranchCodeValidationStyle: InputValidationStyle {
        func validatePartial(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .valid
            }
            let rawValue = BranchCode(rawValue: value).rawValue

            if rawValue.wholeMatch(of: BranchCode.validationPattern) == nil {
                return .invalid(reason: BranchCode.helpMessage)
            }
            return .valid
        }

        func validate(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .invalid(reason: BranchCode.helpMessage)
            }
            let rawValue = BranchCode(rawValue: value).rawValue

            if rawValue.wholeMatch(of: BranchCode.validationPattern) == nil {
                return .invalid(reason: BranchCode.helpMessage)
            }
            return .valid
        }
    }
}

extension InputValidationStyle where Self == BranchCode.BranchCodeValidationStyle {
    static var branchCode: Self {
        .init()
    }
}
