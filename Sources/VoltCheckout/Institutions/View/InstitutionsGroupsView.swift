//
// InstitutionsGroupsView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct InstitutionsGroupsView: View {
    let groups: [Institution.Group]

    @Environment(\.isSearching) private var isSearching

    var body: some View {
        if isSearching {
            InstitutionsGroupsListView(groups: groups)
        } else {
            InstitutionsGroupsGridView(groups: groups)
        }
    }
}
