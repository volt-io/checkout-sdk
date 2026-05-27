//
// ValidationResult.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 10/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package enum ValidationResult: Equatable {
    case valid
    case invalid(reason: String?)

    package var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
}

extension EnvironmentValues {
    @Entry package var inputValidationResult: ValidationResult = .valid
    @Entry package var formValidationResult: ValidationResult = .invalid(reason: nil)
}

struct InputValidationResultKey: PreferenceKey {
    static let defaultValue: ValidationResult = .valid

    static func reduce(value: inout ValidationResult, nextValue: () -> ValidationResult) {
        guard value == .valid else { return }
        value = nextValue()
    }
}
