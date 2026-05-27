//
// VoltTertiaryButtonStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltTertiaryButtonStyle: ButtonStyle {
    package func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.voltSubheadline)
            .foregroundStyle(Color.voltMainSteelColor)
            .padding(.horizontal, .voltPadding6)
            .padding(.vertical, .voltPadding3)
            .background {
                RoundedRectangle(cornerRadius: .voltRadius1)
                    .fill(configuration.isPressed ? Color.voltLightNavyColor : Color.voltSoftNavyColor)
            }
    }
}

extension ButtonStyle where Self == VoltTertiaryButtonStyle {
    package static var voltTertiary: Self {
        VoltTertiaryButtonStyle()
    }
}
