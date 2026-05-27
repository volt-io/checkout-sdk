//
// VoltListLabelStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltListLabelStyle: LabelStyle {
    @ScaledMetric private var logoWidth: CGFloat = 32.0
    @ScaledMetric private var logoPadding: CGFloat = .voltPadding3

    package func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 0) {
            configuration.icon
                .frame(width: logoWidth, height: logoWidth)
                .background(Color.voltHintSteelColor)
                .cornerRadius(.voltRadius2)
                .padding(.horizontal, logoPadding)
            configuration.title
                .font(.voltCallout)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .lineSpacing(.voltLineSpacing)
                .lineLimit(2)
            Spacer()
        }
    }
}

extension LabelStyle where Self == VoltListLabelStyle {
    package static var voltList: Self {
        VoltListLabelStyle()
    }
}
