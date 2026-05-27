//
// InstitutionFlowFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct InstitutionFlowFeature {
    @Reducer
    enum Path {
        case educational(EducationalFeature)
        case institutions(InstitutionsFeature)
        case branches(InstitutionBranchesFeature)
    }

    @ObservableState
    struct State: Equatable {
        let currency: Currency
        let hints: CheckoutHints
        var path = StackState<Path.State>()
    }

    enum Action: FeatureAction {
        @CasePathable
        enum ViewAction {
            case path(StackActionOf<Path>)
        }

        enum DelegateAction {}
        enum InternalAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case _internal(InternalAction)
    }

    @Dependency(\.checkoutResult) var checkoutResult
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            guard let action = action[dynamicMember: \.view.path.element]?.action else { return .none }

            switch (action, state.hints) {
            case let (.educational(.onContinueButtonTapped), .useDefaultCountry(defaultCountry)):
                state.path.append(.institutions(.init(currency: state.currency, defaultCountry: defaultCountry)))
                return .none

            case (.educational(.onContinueButtonTapped), _):
                state.path.append(.institutions(.init(currency: state.currency, defaultCountry: nil)))
                return .none

            case (.institutions(.onTappedGroup(let group)), _):
                state.path.append(.branches(.init(group: group)))
                return .none

            case (.institutions(.onTappedInstitution(let item)), _),
                 (.branches(.onTappedInstitution(let item)), _):
                guard item.isActive else { return .none }

                checkoutResult.yieldResult(.institutionSelected(institution: item.asInstitution))
                return .run { _ in await dismiss(animation: .default) }

            case (.educational(.navBar(.delegate(.onSubmitFeedback))), _),
                 (.institutions(.navBar(.delegate(.onSubmitFeedback))), _),
                 (.branches(.navBar(.delegate(.onSubmitFeedback))), _):
                checkoutResult.yieldResult(nil)
                return .run { _ in await dismiss(animation: .default) }

            default:
                return .none
            }
        }
        .forEach(\.path, action: \.view.path)
    }
}

extension InstitutionFlowFeature.Path.State: Equatable {}
