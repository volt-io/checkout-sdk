//
// Text+VoltCheckout.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 16/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

public import SwiftUI
import VoltDesignSystem

extension Text {
    /// Text modifier that applies style same as used for agreements clause on the SDK onboarding view.
    /// Use it to style agreements clause text in your views as follows:
    ///
    /// ```
    /// Text(VoltCheckout.agreementClause)
    ///     .voltAgreementsClauseTextStyle()
    /// ```
    public func voltAgreementsClauseTextStyle() -> some View {
        self.foregroundStyle(Color.voltMutedSteelColor)
            .tint(Color.voltMainSteelColor)
            .multilineTextAlignment(.center)
            .lineSpacing(VoltFont.lineSpacing(for: .caption))
    }
}
