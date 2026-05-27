//
// VoltTitleLabelStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltTitleLabelStyle: LabelStyle {
    package func makeBody(configuration: Configuration) -> some View {
        configuration.title
            .font(.voltCallout)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .lineSpacing(.voltLineSpacing)
            .lineLimit(2)
            .padding(.voltPadding3)
    }
}

extension LabelStyle where Self == VoltTitleLabelStyle {
    package static var voltTitleOnly: Self {
        VoltTitleLabelStyle()
    }
}
