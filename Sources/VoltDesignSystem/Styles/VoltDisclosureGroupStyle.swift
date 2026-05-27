//
// VoltDisclosureGroupStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltDisclosureGroupStyle: DisclosureGroupStyle {
    package func makeBody(configuration: Configuration) -> some View {
        LazyVStack(alignment: .leading, spacing: .voltPadding3) {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center) {
                    configuration.label
                        .fontWeight(configuration.isExpanded ? .medium : .regular)
                    Spacer()
                    Image.voltChevronRightIcon
                        .foregroundStyle(Color.voltBalancedSteelColor)
                        .rotationEffect(configuration.isExpanded ? .degrees(90) : .zero)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
                Spacer()
            }
        }
    }
}

extension DisclosureGroupStyle where Self == VoltDisclosureGroupStyle {
    package static var voltDisclosureGroup: Self {
        VoltDisclosureGroupStyle()
    }
}
