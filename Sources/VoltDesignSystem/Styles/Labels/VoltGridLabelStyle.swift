//
// VoltGridLabelStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltGridLabelStyle: LabelStyle {
    @ScaledMetric private var logoWidth: CGFloat = 56.0
    @ScaledMetric private var logoPadding: CGFloat = .voltPadding4
    @ScaledMetric private var namePadding: CGFloat = .voltPadding1

    package func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 0) {
            configuration.icon
                .frame(width: logoWidth, height: logoWidth)
                .padding(logoPadding)
            configuration.title
                .font(.voltCaption.weight(.medium))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.9)
                .truncationMode(.tail)
                .lineLimit(3)
                .lineSpacing(2)
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .bottom], namePadding)
        }
    }
}

extension LabelStyle where Self == VoltGridLabelStyle {
    package static var voltGrid: Self {
        VoltGridLabelStyle()
    }
}
