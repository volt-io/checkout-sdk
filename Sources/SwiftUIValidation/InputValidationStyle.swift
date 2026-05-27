//
// InputValidationStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 10/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package protocol InputValidationStyle {
    associatedtype Input

    func validatePartial(_ value: Input) -> ValidationResult
    func validate(_ value: Input) -> ValidationResult
}

struct AnyInputValidationStyle<Input>: InputValidationStyle {
    private let _validatePartial: (Input) -> ValidationResult
    private let _validate: (Input) -> ValidationResult

    init<S: InputValidationStyle>(_ style: S) where S.Input == Input {
        _validatePartial = style.validatePartial
        _validate = style.validate
    }

    func validatePartial(_ value: Input) -> ValidationResult { _validatePartial(value) }
    func validate(_ value: Input) -> ValidationResult { _validate(value) }
}
