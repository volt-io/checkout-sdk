//
// InstitutionGroupRowView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct InstitutionGroupRowView: View {
    let group: Institution.Group
    @State var isExpanded: Bool

    @Environment(\.searchQuery) private var searchQuery: String
    @Environment(\.onTapInstitution) private var onTapInstitution

    var body: some View {
        if group.branches.count == 1, let item = group.branches.first {
            Button {
                onTapInstitution(item)
            } label: {
                InstitutionGroupLabelView(group: group, displayMode: .list)
            }
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(group.branches) { branch in
                    InstitutionItemButtonView(item: branch)
                }
            } label: {
                InstitutionGroupLabelView(group: group, displayMode: .list)
            }
            .disclosureGroupStyle(.voltDisclosureGroup)
            .preference(key: GroupExpandedState.self, value: isExpanded)
        }
    }
}
