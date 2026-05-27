//
// NoResultsView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct NoResultsView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image.voltBankIcon
                .voltPlaceholderImageStyle()
            Text("Still can't find your bank?")
                .padding(.vertical, .voltPadding6)
                .foregroundStyle(Color.voltMainSteelColor)
                .font(.voltCallout)
            Button("Let us know") {
                // TODO: letting us know
            }
            .buttonStyle(.voltTertiary)
        }
        .padding(.voltPadding6)
    }
}
