//
// AccountIdentifiersView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 13/01/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import SwiftUIValidation
import VoltDesignSystem

struct AccountIdentifiersView: View {
    @Perception.Bindable var store: StoreOf<AccountIdentifiersFeature>

    var body: some View {
        WithPerceptionTracking {
            AccountIdentifiersForm(store: store)
                .feedbackSheet(
                    store: $store.scope(state: \.navBar.feedback, action: \._internal.navBar._internal.feedback)
                )
                .checkoutNavBar(store.scope(state: \.navBar, action: \._internal.navBar), title: "Extra details")
                .formValidationGroup()
                .onAppear {
                    store.send(.view(.onAppear))
                }
        }
    }
}
