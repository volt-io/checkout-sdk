//
// InstitutionsGroupsGridView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 22/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SVGView
import SwiftUI
import VoltDesignSystem

struct InstitutionsGroupsGridView: View {
    let groups: [Institution.Group]

    @Environment(\.onTapInstitution) private var onTapInstitution
    @Environment(\.onTapGroup) private var onTapGroup

    var body: some View {
        VoltVGridView {
            ForEach(groups) { group in
                Button {
                    if group.branches.count == 1, let item = group.branches.first {
                        onTapInstitution(item)
                    } else {
                        onTapGroup(group)
                    }
                } label: {
                    InstitutionGroupLabelView(group: group, displayMode: .grid)
                }
            }
        }
    }
}
