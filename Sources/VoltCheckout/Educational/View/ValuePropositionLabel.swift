//
// ValuePropositionLabel.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 15/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct ValuePropositionLabel: View {
    let title: String
    let subtitle: String
    let icon: () -> Image

    var body: some View {
        HStack(alignment: .center, spacing: .voltPadding3) {
            icon()
                .padding(.voltPadding4)
            VStack(alignment: .leading, spacing: .voltPadding3) {
                Text(title)
                    .foregroundStyle(Color.voltMainSteelColor)
                    .font(.voltHeadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .foregroundStyle(Color.voltMutedSteelColor)
                    .font(.voltSubheadline)
            }
        }
    }
}
