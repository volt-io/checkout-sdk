//
// AccountIdentifiersFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 13/01/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AccountIdentifiersFeature {
    @ObservableState
    struct State: Equatable {
        let institution: Institution.Item
        let country: Country
        var data: AccountIdentifiersData
        var navBar: CheckoutNavBarFeature.State = .backButtonHidden(with: AccountIdentifiersFeedback())

        init(institution: Institution.Item, country: Country) {
            self.institution = institution
            self.country = country
            self.data = AccountIdentifiersData(institution.accountIdentifiers, countryCode: country.locale)
            self.navBar = navBar
        }
    }

    enum Action: FeatureAction, BindableAction {
        @CasePathable
        enum ViewAction {
            case onAppear
            case onContinueButtonTapped
        }

        @CasePathable
        enum DelegateAction {
            case onSubmitted(AccountIdentifiersData)
            case onReturnToMerchant
        }

        @CasePathable
        enum InternalAction {
            case navBar(CheckoutNavBarFeature.Action)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case _internal(InternalAction)
        case binding(BindingAction<State>)
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Scope(state: \.navBar, action: \._internal.navBar) {
            CheckoutNavBarFeature()
        }
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                handleOnAppear(with: &state)
            case .view(.onContinueButtonTapped):
                handleOnContinueButtonTapped(with: &state)
            case ._internal(.navBar(.delegate(.onSubmitFeedback))):
                .send(.delegate(.onReturnToMerchant))
            default:
                .none
            }
        }
        BindingReducer()
    }

    // MARK: - View Actions

    func handleOnAppear(with _: inout State) -> Effect<Action> {
        .none
    }

    func handleOnContinueButtonTapped(with state: inout State) -> Effect<Action> {
        .send(.delegate(.onSubmitted(state.data)))
    }
}
