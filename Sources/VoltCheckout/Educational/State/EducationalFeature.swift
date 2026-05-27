//
// EducationalFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 08/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct EducationalFeature {
    @ObservableState
    struct State: Equatable {
        var navBar: CheckoutNavBarFeature.State = .backButtonHidden(with: EducationalFeedback())
    }

    enum Action {
        case onAppear
        case onContinueButtonTapped
        case onTermsAndConditionsTapped
        case navBar(CheckoutNavBarFeature.Action)
    }

    @Dependency(\.analytics.track) var track

    var body: some Reducer<State, Action> {
        Scope(state: \.navBar, action: \.navBar) {
            CheckoutNavBarFeature()
        }
        Reduce { _, action in
            switch action {
            case .onAppear:
                track(.openBankingPage, [:])
            case .onContinueButtonTapped:
                track(.continueOnWelcomeView, [:])
            case .onTermsAndConditionsTapped:
                track(.openTermsAndConditions, [:])
            default:
                return .none
            }
            return .none
        }
    }
}
