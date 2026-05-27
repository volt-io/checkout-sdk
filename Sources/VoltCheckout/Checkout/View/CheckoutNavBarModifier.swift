//
// CheckoutNavBarModifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct CheckoutNavBarModifier<L, T>: ViewModifier where L: View, T: View {
    let store: StoreOf<CheckoutNavBarFeature>
    @ViewBuilder let leftItem: () -> L
    @ViewBuilder let title: () -> T

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .voltNavigationBackButtonStyle()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(store.hidesBackButton)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        leftItem()
                    }
                    ToolbarItem(placement: .principal) {
                        title()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        VoltCloseButton {
                            store.send(.view(.onCloseButtonTapped))
                        }
                    }
                }
        }
    }
}

extension View {
    func checkoutNavBar<T>(
        _ store: StoreOf<CheckoutNavBarFeature>,
        @ViewBuilder title: @escaping () -> T
    ) -> some View where T: View {
        modifier(CheckoutNavBarModifier(store: store, leftItem: {
            EmptyView()
        }, title: title))
    }

    func checkoutNavBar<L>(
        _ store: StoreOf<CheckoutNavBarFeature>,
        title: String,
        @ViewBuilder leftItem: @escaping () -> L = { EmptyView() }
    ) -> some View where L: View {
        modifier(CheckoutNavBarModifier(store: store, leftItem: leftItem) {
            Text(title)
                .voltNavigationTitleStyle()
        })
    }

    func checkoutNavBar(
        _ store: StoreOf<CheckoutNavBarFeature>
    ) -> some View {
        modifier(CheckoutNavBarModifier(store: store) {
            EmptyView()
        } title: {
            EmptyView()
        })
    }
}
