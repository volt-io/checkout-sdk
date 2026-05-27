//
// CheckoutSheetModifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CheckoutSheetModifier: ViewModifier {
    @Perception.Bindable var store: StoreOf<CheckoutRootFeature>
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .fullScreenCover(item: $store.scope(state: \.flow?.institution, action: \.view.flow.institution)) {
                    InstitutionFlowView(store: $0)
                }
                .fullScreenCover(item: $store.scope(state: \.flow?.payment, action: \.view.flow.payment)) {
                    PaymentFlowView(store: $0)
                }
                .onChange(of: scenePhase) { newScenePhase in
                    store.send(.view(.onScenePhaseChange(newScenePhase)))
                }
                .onAppear {
                    store.send(.view(.onAppear))
                }
        }
    }
}
