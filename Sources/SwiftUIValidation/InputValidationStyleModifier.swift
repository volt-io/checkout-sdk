//
// InputValidationStyleModifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 10/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

private struct InputValidationStyleModifier<Input>: ViewModifier {
    let style: AnyInputValidationStyle<Input>
    let value: Input

    func body(content: Content) -> some View {
        content
            .environment(\.inputValidationResult, style.validatePartial(value))
            .preference(key: InputValidationResultKey.self, value: style.validate(value))
    }
}

extension View {
    package func validationStyle<S: InputValidationStyle>(
        _ style: S,
        for value: S.Input,
    ) -> some View {
        modifier(InputValidationStyleModifier(
            style: AnyInputValidationStyle(style),
            value: value,
        ))
    }
}
