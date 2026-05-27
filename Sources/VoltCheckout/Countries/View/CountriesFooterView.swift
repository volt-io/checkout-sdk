//
// CountriesFooterView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 30/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import VoltDesignSystem

struct CountriesFooterView: View {
    @Environment(\.onTapCancel) private var onTapCancel

    private var messageText: AttributedString {
        var string = AttributedString(localized:
            """
            Can't find your country? Sorry, you'll need to
            cancel the payment.
            """
        )

        guard let cancelRange = string.range(of: "cancel the payment") else { return string }

        string.font = .voltSubheadline.weight(.medium)
        string[cancelRange].foregroundColor = .voltMainBlueColor

        return string
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: onTapCancel) {
                Text(messageText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(VoltFont.lineSpacing(for: .subheadline))
                    .padding([.leading, .top, .trailing], .voltPadding6)
            }
        }
        .padding(.horizontal, .voltPadding5 * -1)
        .background(alignment: .top) {
            Color.voltTranslucentNavyColor
                .frame(height: 9999) // magic number ftw
        }
    }
}
