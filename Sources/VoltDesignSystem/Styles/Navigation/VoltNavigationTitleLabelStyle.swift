//
// VoltNavigationTitleLabelStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltNavigationTitleLabelStyle: LabelStyle {
    @ScaledMetric private var logoWidth: CGFloat = 24.0
    @ScaledMetric private var logoPadding: CGFloat = .voltPadding3

    package func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 0) {
            configuration.icon
                .frame(width: logoWidth, height: logoWidth)
                .background(Color.voltHintSteelColor)
                .cornerRadius(.voltRadius2)
                .padding(.horizontal, logoPadding)
            configuration.title
        }
    }
}

extension LabelStyle where Self == VoltNavigationTitleLabelStyle {
    package static var voltNavigationTitle: Self {
        VoltNavigationTitleLabelStyle()
    }
}
