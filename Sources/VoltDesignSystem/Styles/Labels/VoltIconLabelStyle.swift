//
// VoltIconLabelStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltIconLabelStyle: LabelStyle {
    @ScaledMetric private var iconSize: CGFloat = 24.0

    package func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .aspectRatio(1, contentMode: .fit)
            .frame(width: iconSize)
    }
}

extension LabelStyle where Self == VoltIconLabelStyle {
    package static var voltIconOnly: Self {
        VoltIconLabelStyle()
    }
}
