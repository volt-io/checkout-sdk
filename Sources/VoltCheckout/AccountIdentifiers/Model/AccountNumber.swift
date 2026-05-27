//
// AccountNumber.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import SwiftUIValidation

struct AccountNumber: Equatable, Hashable {
    let countryCode: Locale.Region
    let number: String

    var maxLength: Int {
        countryCode == .unitedKingdom ? 8 : 7
    }

    var sanitizedValue: String {
        String(number.filter(\.isNumber).prefix(maxLength))
    }

    static func prompt(for countryCode: Locale.Region) -> String {
        "1234567\(countryCode == .unitedKingdom ? "8" : "")"
    }

    static func helpMessage(for countryCode: Locale.Region) -> String {
        "\(countryCode == .unitedKingdom ? "8" : "7") digit number"
    }

    static func validationPattern(for countryCode: Locale.Region) -> Regex<Substring> {
        countryCode == .unitedKingdom ? /^[0-9]{8}$/ : /^[0-9]{7}$/
    }
}

// MARK: - Formatting

extension AccountNumber {
    struct AccountNumberParseStrategy: ParseStrategy {
        let countryCode: Locale.Region

        func parse(_ value: String) -> AccountNumber {
            AccountNumber(countryCode: countryCode, number: value)
        }
    }

    struct AccountNumberFormatStyle: ParseableFormatStyle {
        var parseStrategy: AccountNumberParseStrategy

        init(countryCode: Locale.Region) {
            self.parseStrategy = .init(countryCode: countryCode)
        }

        func format(_ value: AccountNumber) -> String {
            value.number
        }
    }

    func formatted(_ formatStyle: AccountNumberFormatStyle) -> String {
        formatStyle.format(self)
    }
}

extension ParseableFormatStyle where Self == AccountNumber.AccountNumberFormatStyle {
    static func accountNumber(_ countryCode: Locale.Region) -> Self {
        .init(countryCode: countryCode)
    }
}

// MARK: - Validation

extension AccountNumber {
    struct AccountNumberValidationStyle: InputValidationStyle {
        let countryCode: Locale.Region

        func validatePartial(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .valid
            }

            if value.wholeMatch(of: AccountNumber.validationPattern(for: countryCode)) == nil {
                return .invalid(reason: AccountNumber.helpMessage(for: countryCode))
            }
            return .valid
        }

        func validate(_ value: String?) -> ValidationResult {
            guard let value, !value.isEmpty else {
                return .invalid(reason: AccountNumber.helpMessage(for: countryCode))
            }

            if value.wholeMatch(of: AccountNumber.validationPattern(for: countryCode)) == nil {
                return .invalid(reason: AccountNumber.helpMessage(for: countryCode))
            }
            return .valid
        }
    }
}

extension InputValidationStyle where Self == AccountNumber.AccountNumberValidationStyle {
    static func accountNumber(_ countryCode: Locale.Region) -> Self {
        .init(countryCode: countryCode)
    }
}
