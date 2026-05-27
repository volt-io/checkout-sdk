//
// VoltCountryItemLabel.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltCountryItemLabel: View {
    package let country: Locale.Region

    package init(country: Locale.Region) {
        self.country = country
    }

    package var body: some View {
        Label {
            Text(Locale.current.localizedString(forRegionCode: country.identifier) ?? "")
        } icon: {
            Image(ImageResource(name: country.identifier, bundle: .module))
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .background {
                    Circle()
                        .stroke(Color.voltMainSteelColor.opacity(0.16))
                }
                .accessibilityHidden(true)
        }
        .labelStyle(.voltGrid)
    }
}
