//
// VoltPrimaryButtonStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 03/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    package func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.voltCallout)
            .fontWeight(.medium)
            .foregroundStyle(isEnabled ? .white : .voltFaintSteelColor)
            .padding(.horizontal, .voltPadding6)
            .padding(.vertical, .voltPadding5 + .voltPadding1)
            .background {
                RoundedRectangle(cornerRadius: .voltRadius1)
                    .fill(!isEnabled ? Color.voltSoftNavyColor :
                            configuration.isPressed ? .voltBalancedNavyColor : .voltMainNavyColor)
            }
    }
}

extension ButtonStyle where Self == VoltPrimaryButtonStyle {
    package static var voltPrimary: Self {
        VoltPrimaryButtonStyle()
    }
}
