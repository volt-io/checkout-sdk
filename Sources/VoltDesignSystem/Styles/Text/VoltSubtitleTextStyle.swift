//
// VoltSubtitleTextStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/02/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension Text {
    package func voltSubtitleTextStyle() -> some View {
        self.font(.voltSubheadline)
            .multilineTextAlignment(.center)
            .lineSpacing(VoltFont.lineSpacing(for: .subheadline))
            .foregroundStyle(Color.voltMutedNavyColor)
    }
}
