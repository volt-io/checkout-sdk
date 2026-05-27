//
// PaymentView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 21/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct PaymentView: View {
    @Perception.Bindable var store: StoreOf<PaymentFeature>
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .center, spacing: 0.0) {
                VoltStatusView(state: store.progressState.viewState) {
                    AsyncSVGImage(url: store.institution.logo) {
                        Image.voltBankIcon
                            .voltPlaceholderImageStyle()
                    } failed: {
                        Image.voltBankIcon
                            .voltPlaceholderImageStyle()
                    }
                    .background(Color.voltHintSteelColor)
                    .cornerRadius(.voltRadius3)
                } header: {
                    Text(store.progressState.title)
                } description: {
                    Text(store.progressState.description)
                }
                actionButtons
            }
            .padding(.voltPadding5)
            .feedbackSheet(store: $store.scope(state: \.navBar.feedback, action: \._internal.navBar._internal.feedback))
            .checkoutNavBar(store.scope(state: \.navBar, action: \._internal.navBar))
            .onChange(of: scenePhase) { newScenePhase in
                store.send(.view(.onScenePhaseChange(newScenePhase)))
            }
            .onAppear {
                store.send(.view(.onAppear))
            }
        }
    }

    @ViewBuilder private var actionButtons: some View {
        switch store.progressState {
        case .succeeded, .delayed:
            returnToMerchantButton
                .buttonStyle(.voltPrimary)
            heightPlaceholderButton
                .buttonStyle(.voltSecondary)
        case .failed:
            selectAnotherBankButton
                .buttonStyle(.voltPrimary)
            returnToMerchantButton
                .buttonStyle(.voltSecondary)
        default:
            heightPlaceholderButton
                .buttonStyle(.voltPrimary)
            heightPlaceholderButton
                .buttonStyle(.voltSecondary)
        }
    }

    private var returnToMerchantButton: some View {
        ActionButton(label: "Return to Merchant") {
            store.send(.view(.onReturnToMerchantTapped))
        }
    }

    private var selectAnotherBankButton: some View {
        ActionButton(label: "Select Another Bank") {
            store.send(.view(.onSelectAnotherBankTapped))
        }
    }

    private var heightPlaceholderButton: some View {
        ActionButton(label: "Placeholder", action: {})
            .accessibilityHidden(true)
            .hidden()
    }

    struct ActionButton: View {
        let label: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(label)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, .voltPadding5)
            .padding(.vertical, .voltPadding3)
        }
    }
}
