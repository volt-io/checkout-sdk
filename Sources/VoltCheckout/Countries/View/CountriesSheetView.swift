//
// CountriesSheetView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct CountriesSheetView: View {
    let countries: [Country]

    @State private var contentHeight: CGFloat = 0.0
    @State private var isVerticalSizeFixed = true

    var body: some View {
        GeometryReader { containerProxy in
            VStack {
                CountriesHeaderView()
                CountriesGridView(countries: countries)
            }
            .fixedSize(horizontal: false, vertical: isVerticalSizeFixed)
            .onGeometryChange(for: CGFloat.self, of: { proxy in
                proxy.size.height
            }, action: { newHeight in
                contentHeight = newHeight
                isVerticalSizeFixed = contentHeight < containerProxy.size.height
            })
            .presentationDetents([.height(contentHeight)])
            .presentationCornerRadius(.voltRadius2)
            .tint(.voltMainSteelColor)
        }
    }
}
