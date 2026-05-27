//
// VoltChangeCountryLabel.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 24/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltChangeCountryLabel: View {
    package let country: Locale.Region
    package let showsChevron: Bool

    package init(country: Locale.Region, showsChevron: Bool) {
        self.country = country
        self.showsChevron = showsChevron
    }

    @ScaledMetric private var stackSpacing: CGFloat = 5.0
    @ScaledMetric private var flagWidth: CGFloat = 24.0
    @ScaledMetric private var chevronWidth: CGFloat = 16.0

    package var body: some View {
        HStack(spacing: stackSpacing) {
            Image(ImageResource(name: country.identifier, bundle: .module))
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: flagWidth)
            Text(country.identifier.uppercased())
                .font(.voltSubheadline)
                .fontWeight(.medium)
            if showsChevron {
                Image.voltChevronRightIcon
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: chevronWidth)
                    .offset(x: -1.0)
                    .rotationEffect(.degrees(90))
            }
        }
        .accessibilityLabel(Locale.current.localizedString(forRegionCode: country.identifier) ?? "Unknown country")
    }
}
