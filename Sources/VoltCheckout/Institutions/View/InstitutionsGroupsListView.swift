//
// InstitutionsGroupsListView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct InstitutionsGroupsListView: View {
    let groups: [Institution.Group]

    @Environment(\.searchQuery) private var searchQuery: String
    @ScaledMetric private var itemSpacing: CGFloat = .voltPadding5
    @State private var groupsExpandedState = Set<String>()
    @Namespace private var topID

    private var itemsCount: Int {
        groups.reduce(into: 0, { $0 += $1.branches.count })
    }
    private var headerTitle: String {
        searchQuery.isEmpty ? "Popular" : "\(itemsCount) Results"
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: itemSpacing) {
                    Section {
                        if groups.isEmpty {
                            NoResultsView()
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(groups) { group in
                                InstitutionGroupRowView(group: group, isExpanded: groupsExpandedState.contains(group.id))
                                    .onPreferenceChange(GroupExpandedState.self) { isExpanded in
                                        set(isExpanded, for: group.id)
                                    }
                            }
                        }
                    } header: {
                        sectionHeader
                    }
                }
                .padding(.horizontal, .voltPadding5)
                .id(groups.count)
            }
            .onChange(of: searchQuery) { _ in
                proxy.scrollTo(topID)
            }
        }
    }

    private var sectionHeader: some View {
        Text(headerTitle)
            .voltSectionTitleTextStyle()
            .id(topID)
    }

    private func set(_ isExpanded: Bool, for groupId: String) {
        if isExpanded {
            groupsExpandedState.insert(groupId)
        } else {
            groupsExpandedState.remove(groupId)
        }
    }
}
