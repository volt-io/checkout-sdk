//
// InstitutionsView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 30/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct InstitutionsView: View {
    @Perception.Bindable var store: StoreOf<InstitutionsFeature>

    var body: some View {
        WithPerceptionTracking {
            InstitutionsGroupsView(groups: store.groups)
                .environment(\.searchQuery, store.searchQuery)
                .environment(\.onTapGroup, { store.send(.onTappedGroup($0)) })
                .environment(\.onTapInstitution, { store.send(.onTappedInstitution($0)) })
                .searchable(
                    text: $store.searchQuery.sending(\.onSearchQueryChanged),
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Search by bank name")
                )
                .voltSearchBarStyle()
                .overlay {
                    if case .loading = store.loadingState {
                        ProgressView()
                            .tint(Color.voltMainSteelColor)
                    }
                }
                .overlay {
                    if let error = store.error {
                        Label(error, systemImage: "exclamationmark.triangle")
                    }
                }
                .sheet(isPresented: $store.isCountriesSheetPresented.sending(\.onPresentingCountrySelection)) {
                    CountriesSheetView(countries: store.countries)
                        .environment(\.selectedCountry, store.selectedCountry)
                        .environment(\.onTapCountry, {
                            store.send(.onSelectedCountryChanged($0))
                        })
                        .environment(\.onTapCancel, {
                            store.send(.onPresentingCountrySelection(false))
                            store.send(.navBar(.view(.onCloseButtonTapped)))
                        })
                        .presentationDragIndicator(store.selectedCountry == nil ? .hidden : .visible)
                        .interactiveDismissDisabled(store.selectedCountry == nil)
                }
                .disabledItemPopover($store.popoverItem.sending(\.onPopoverItemChanged))
                .feedbackSheet(store: $store.scope(state: \.navBar.feedback, action: \.navBar._internal.feedback))
                .checkoutNavBar(store.scope(state: \.navBar, action: \.navBar), title: "Select your bank") {
                    SelectedCountryView(isEnabled: store.countries.count > 1) {
                        store.send(.onPresentingCountrySelection(true))
                    }
                    .environment(\.selectedCountry, store.selectedCountry)
                }
                .onAppear {
                    store.send(.onAppear)
                }
        }
    }
}
