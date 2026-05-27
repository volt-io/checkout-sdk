//
// VoltSectionTitleTextStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension Text {
    package func voltSectionTitleTextStyle() -> some View {
        self.font(.voltSubheadline.weight(.medium))
            .foregroundStyle(Color.voltMainSteelColor)
            .padding(.horizontal, .voltPadding3)
            .padding(.bottom, .voltPadding2)
            .padding(.top, .voltPadding4)
    }
}
