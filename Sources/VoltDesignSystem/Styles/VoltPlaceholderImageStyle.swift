//
// VoltPlaceholderImageStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltPlaceholderImageStyle: ViewModifier {
    @ScaledMetric private var imageWidth: CGFloat = 56.0

    package func body(content: Content) -> some View {
        content
            .frame(width: imageWidth, height: imageWidth)
            .foregroundStyle(Color.voltHazySteelColor)
            .background(Color.voltHintSteelColor)
            .cornerRadius(.voltRadius3)
    }
}

extension Image {
    package func voltPlaceholderImageStyle() -> some View {
        modifier(VoltPlaceholderImageStyle())
    }
}
