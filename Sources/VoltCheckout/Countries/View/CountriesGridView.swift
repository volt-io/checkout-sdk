//
// CountriesGridView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 30/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import VoltDesignSystem

struct CountriesGridView: View {
    let countries: [Country]

    @Environment(\.onTapCountry) private var onTapCountry

    var body: some View {
        VoltVGridView {
            ForEach(countries, id: \.self) { country in
                Button {
                    onTapCountry(country)
                } label: {
                    VoltCountryItemLabel(country: country.locale)
                }
            }
        } footer: {
            CountriesFooterView()
        }
    }
}
