//
// InstitutionBranchesView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct InstitutionBranchesView: View {
    @Perception.Bindable var store: StoreOf<InstitutionBranchesFeature>

    @Environment(\.onTapInstitution) private var onTapInstitution
    @ScaledMetric private var itemSpacing: CGFloat = .voltPadding5
    @Namespace private var topID

    private var headerTitle: String {
        store.searchQuery.isEmpty ? "All branches" : "\(store.items.count) Results"
    }

    var body: some View {
        ScrollViewReader { proxy in
            WithPerceptionTracking {
                ScrollView {
                    Section {
                        LazyVStack(alignment: .leading, spacing: itemSpacing) {
                            ForEach(store.items) { item in
                                InstitutionItemButtonView(item: item)
                                    .environment(\.onTapInstitution, { store.send(.onTappedInstitution($0)) })
                            }
                        }
                    } header: {
                        sectionHeader
                    }
                    .padding(.horizontal, .voltPadding5)
                }
                .searchable(
                    text: $store.searchQuery.sending(\.onSearchQueryChanged),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Search by branch name")
                )
                .voltSearchBarStyle()
                .onChange(of: store.searchQuery) { _ in
                    proxy.scrollTo(topID)
                }
                .disabledItemPopover($store.popoverItem.sending(\.onPopoverItemChanged))
                .feedbackSheet(store: $store.scope(state: \.navBar.feedback, action: \.navBar._internal.feedback))
                .checkoutNavBar(store.scope(state: \.navBar, action: \.navBar)) {
                    navBarTitle
                }
                .onAppear {
                    store.send(.onAppear)
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text(headerTitle)
                .voltSectionTitleTextStyle()
            Spacer()
        }
        .id(topID)
    }

    private var navBarTitle: some View {
        Label {
            Text("Select branch")
                .voltNavigationTitleStyle()
        } icon: {
            AsyncSVGImage(url: store.group.logo) {
                ProgressView()
            } failed: {
                EmptyView()
            }
        }
        .labelStyle(.voltNavigationTitle)
    }
}
