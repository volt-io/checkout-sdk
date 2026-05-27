//
// VoltRadioToggleStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 19/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltRadioToggleStyle: ToggleStyle {
    @ScaledMetric private var outerDiameter: CGFloat = 24.0
    @ScaledMetric private var innerDiameter: CGFloat = 16.0
    @ScaledMetric private var strokeWidth: CGFloat = .voltStroke1
    @Environment(\.isEnabled) private var isEnabled

    package func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: .voltPadding5) {
                ZStack {
                    Circle()
                        .stroke(outerColor(for: configuration), lineWidth: strokeWidth)
                        .frame(width: outerDiameter, height: outerDiameter)
                    Circle()
                        .fill(innerColor(for: configuration))
                        .frame(width: innerDiameter, height: innerDiameter)
                }
                configuration.label
                    .foregroundStyle(labelColor(for: configuration))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
    }

    private func outerColor(for configuration: Configuration) -> Color {
        if !isEnabled {
            .voltHazyNavyColor
        } else if configuration.isOn {
            .voltMainNavyColor
        } else {
            .voltFaintNavyColor
        }
    }

    private func innerColor(for configuration: Configuration) -> Color {
        if configuration.isMixed {
            .voltSoftNavyColor
        } else if configuration.isOn {
            !isEnabled ? .voltHazyNavyColor : .voltMainNavyColor
        } else {
            .clear
        }
    }

    private func labelColor(for configuration: Configuration) -> Color {
        if !isEnabled {
            .voltHazySteelColor
        } else if configuration.isOn {
            .voltMainSteelColor
        } else {
            .voltMutedSteelColor
        }
    }
}

extension ToggleStyle where Self == VoltRadioToggleStyle {
    package static var voltRadio: Self {
        VoltRadioToggleStyle()
    }
}
