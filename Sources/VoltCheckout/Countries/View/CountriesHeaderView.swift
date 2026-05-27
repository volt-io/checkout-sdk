//
// CountriesHeaderView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import VoltDesignSystem

struct CountriesHeaderView: View {
    @Environment(\.selectedCountry) private var selectedCountry
    @Environment(\.onTapCancel) private var onTapCancel

    var body: some View {
        if selectedCountry == nil {
            ZStack(alignment: .center) {
                title
                HStack {
                    Spacer()
                    VoltCloseButton(action: onTapCancel)
                        .padding(.top, .voltPadding7)
                        .padding(.trailing, .voltPadding6)
                }
            }
        } else {
            title
        }
    }

    var title: some View {
        Text("Select country")
            .voltNavigationTitleStyle()
            .padding(.top, .voltPadding7)
    }
}
