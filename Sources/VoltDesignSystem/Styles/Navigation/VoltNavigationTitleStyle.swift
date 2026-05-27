//
// VoltNavigationTitleStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 04/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension Text {
    package func voltNavigationTitleStyle() -> some View {
        self.font(.voltTitle3.weight(.medium))
            .foregroundStyle(Color.voltMainSteelColor)
    }
}
