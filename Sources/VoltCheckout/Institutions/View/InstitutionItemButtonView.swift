//
// InstitutionItemButtonView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import VoltDesignSystem

struct InstitutionItemButtonView: View {
    let item: Institution.Item

    @Environment(\.onTapInstitution) private var onTapInstitution

    var body: some View {
        Button {
            onTapInstitution(item)
        } label: {
            HStack {
                Label {
                    Text(item.branchName ?? item.name)
                } icon: {
                    EmptyView()
                }
                .labelStyle(.voltTitleOnly)
                .tint(!item.isActive ? .voltFaintSteelColor : .voltBalancedSteelColor)
                Spacer()
            }
        }
    }
}
