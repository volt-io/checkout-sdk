//
// VoltSecondaryButtonStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 27/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltSecondaryButtonStyle: ButtonStyle {
    package func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.voltCallout)
            .fontWeight(.medium)
            .foregroundStyle(Color.voltMainSteelColor)
            .padding(.horizontal, .voltPadding6)
            .padding(.vertical, .voltPadding5 + .voltPadding1)
            .background {
                RoundedRectangle(cornerRadius: .voltRadius1)
                    .fill(configuration.isPressed ? Color.voltSoftNavyColor : Color.white)
            }
            .overlay {
                RoundedRectangle(cornerRadius: .voltRadius1)
                    .stroke(Color.voltLightNavyColor, lineWidth: .voltStroke1)
            }
    }
}

extension ButtonStyle where Self == VoltSecondaryButtonStyle {
    package static var voltSecondary: Self {
        VoltSecondaryButtonStyle()
    }
}
