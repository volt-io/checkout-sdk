//
// GraphicTitleLabel.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 15/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct GraphicTitleLabel: View {
    let leftIcon: () -> Image
    let rightIcon: () -> Image
    let title: () -> Text

    private let iconSize: CGFloat = 56.0

    var body: some View {
        VStack(alignment: .center, spacing: .voltSpacing7) {
            HStack(alignment: .center, spacing: .voltPadding4) {
                leftIcon()
                    .padding(.voltPadding5)
                    .frame(width: iconSize, height: iconSize)
                    .background {
                        RoundedRectangle(cornerRadius: .voltRadius3)
                            .fill(.background)
                            .shadow(color: .voltMainSteelColor.opacity(0.16), radius: .voltRadius5, y: .voltPadding3)
                    }
                rightIcon()
                    .padding(.voltPadding5)
                    .frame(width: iconSize, height: iconSize)
                    .background {
                        RoundedRectangle(cornerRadius: .voltRadius3)
                            .fill(Color.voltMainSteelColor)
                    }
            }
            title()
                .font(.voltTitle)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.voltMainSteelColor)
        }
    }
}
