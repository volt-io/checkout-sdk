//
// IBAN.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 03/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import SwiftUIValidation

struct IBAN: Equatable, Hashable {
    let country: Locale.Region
    let BBAN: String

    static let maxLength = 34
    static let helpMessage = "Your IBAN is up to 34 characters and starts with 2 letters."
    nonisolated(unsafe) static let validationPattern = /^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$/
}

extension IBAN: RawRepresentable {
    init(rawValue: String) {
        var countryCode = ""
        var BBAN = ""

        for char in rawValue {
            guard !char.isWhitespace else { continue }

            if countryCode.count < 2 {
                countryCode.append(char)
            } else {
                BBAN.append(char)
            }
        }

        self.init(country: .init(countryCode), BBAN: BBAN)
    }
    
    var rawValue: String {
        country.identifier + BBAN
    }

    var sanitizedValue: String {
        String(rawValue.filter { $0.isASCII && ($0.isLetter || $0.isNumber) }.prefix(Self.maxLength))
    }
}

extension IBAN: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self = IBAN(rawValue: value)
    }
}

// MARK: - Formatting

extension IBAN {
    struct IBANParseStrategy: ParseStrategy {
        func parse(_ value: String) -> IBAN {
            IBAN(rawValue: value)
        }
    }

    struct IBANFormatStyle: ParseableFormatStyle {
        var parseStrategy = IBANParseStrategy()

        func format(_ value: IBAN) -> String {
            let string = value.rawValue
            return stride(from: 0, to: string.count, by: 4).map { offset in
                let start = string.index(string.startIndex, offsetBy: offset)
                let end = string.index(start, offsetBy: min(4, string.count - offset))
                return String(string[start..<end])
            }.joined(separator: " ")
        }
    }

    func formatted(_ formatStyle: IBANFormatStyle) -> String {
        formatStyle.format(self)
    }
}

extension FormatStyle where Self == IBAN.IBANFormatStyle {
    static var iban: Self {
        .init()
    }
}

// MARK: - Validation

extension IBAN {
    struct IBANValidationStyle: InputValidationStyle {
        func validatePartial(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .valid
            }
            let rawValue = IBAN(rawValue: value).rawValue

            if rawValue.wholeMatch(of: IBAN.validationPattern) == nil {
                return .invalid(reason: IBAN.helpMessage)
            }
            return .valid
        }

        func validate(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .invalid(reason: IBAN.helpMessage)
            }
            let rawValue = IBAN(rawValue: value).rawValue

            if rawValue.wholeMatch(of: IBAN.validationPattern) == nil {
                return .invalid(reason: IBAN.helpMessage)
            }
            return .valid
        }
    }
}

extension InputValidationStyle where Self == IBAN.IBANValidationStyle {
    static var iban: Self {
        .init()
    }
}
