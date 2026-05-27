//
// PaymentFlowView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct PaymentFlowView: View {
    @Perception.Bindable var store: StoreOf<PaymentFlowFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.view.path)) {
                EmptyView()
            } destination: { store in
                WithPerceptionTracking {
                    switch store.case {
                    case let .educational(store):
                        EducationalView(store: store)
                    case let .institutions(store):
                        InstitutionsView(store: store)
                    case let .branches(store):
                        InstitutionBranchesView(store: store)
                    case let .payment(store):
                        PaymentView(store: store)
                    case let .accountIdentifiers(store):
                        AccountIdentifiersView(store: store)
                    }
                }
            }
            .accentColor(.voltMainSteelColor)
        }
    }
}
