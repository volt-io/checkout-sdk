//
// VoltHeadlineTextStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension Text {
    package func voltHeadlineTextStyle() -> some View {
        self.font(.voltSubheadline)
            .foregroundStyle(Color.voltMutedSteelColor)
            .lineSpacing(VoltFont.lineSpacing(for: .subheadline))
            .multilineTextAlignment(.center)
    }
}
