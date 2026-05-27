//
// FormValidationGroupModifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct FormValidationGroupModifier: ViewModifier {
    @State private var result: ValidationResult

    package func body(content: Content) -> some View {
        content
            .onPreferenceChange(InputValidationResultKey.self) { result = $0 }
            .environment(\.formValidationResult, result)
    }
}

extension FormValidationGroupModifier {
    package init(initialResult: ValidationResult) {
        self.result = initialResult
    }
}

extension View {
    package func formValidationGroup(initialResult: ValidationResult = .invalid(reason: nil)) -> some View {
        modifier(FormValidationGroupModifier(initialResult: initialResult))
    }
}
