//
// SelectedCountryView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import VoltDesignSystem

struct SelectedCountryView: View {
    let isEnabled: Bool
    let action: () -> Void

    @Environment(\.selectedCountry) private var selectedCountry

    var body: some View {
        if let selectedCountry {
            if isEnabled {
                Button(action: action) {
                    VoltChangeCountryLabel(country: selectedCountry.locale, showsChevron: true)
                }
                .accessibilityLabel("Change country")
            } else {
                VoltChangeCountryLabel(country: selectedCountry.locale, showsChevron: false)
            }
        }
    }
}
