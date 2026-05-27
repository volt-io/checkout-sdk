//
// VoltSearchBarStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension View {
    package func voltSearchBarStyle() -> some View {
        modifier(CustomSearchBarModifier(
            icons: [
                .search: .voltSearchIcon.withTintColor(.voltMainSteelColor, renderingMode: .alwaysOriginal),
                .clear: .voltClearIcon.withRenderingMode(.alwaysOriginal),
            ],
            tintColors: [
                .bar: .voltMainBlueColor,
                .field: .voltMainSteelColor,
                .prompt: .voltFaintSteelColor,
            ],
            backgroundImages: [.field: UIImage()],
            backgroundColor: .voltTranslucentNavyColor,
            selectedBorder: .init(color: .voltMainBlueColor, width: 1.0),
            border: .init(color: .voltLightNavyColor, width: 1.0),
            corner: .init(radius: .voltRadius1, curve: .circular)
        ))
    }
}
