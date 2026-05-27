//
// PaymentFlowFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 08/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct PaymentFlowFeature {
    @Reducer
    enum Path {
        case educational(EducationalFeature)
        case institutions(InstitutionsFeature)
        case branches(InstitutionBranchesFeature)
        case payment(PaymentFeature)
        case accountIdentifiers(AccountIdentifiersFeature)
    }

    @ObservableState
    struct State: Equatable {
        let intent: PaymentIntent
        let hints: CheckoutHints
        var path = StackState<Path.State>()
        var selectedInstitution: Institution?
        var selectedCountry: Country?
        var paymentIdentifier: PaymentIdentifier?
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

            return switch (action, state.hints) {
            case (.educational(.onContinueButtonTapped), .useDefaultCountry(let defaultCountry)):
                handleEducationalContinueWithDefaultCountry(state: &state, defaultCountry: defaultCountry)

            case (.educational(.onContinueButtonTapped), _):
                handleEducationalContinue(state: &state)

            case (.institutions(.onSelectedCountryChanged(let selectedCountry)), _):
                handleSelectedCountryChanged(state: &state, selectedCountry: selectedCountry)

            case (.institutions(.onTappedGroup(let group)), _):
                handleTappedGroup(state: &state, group: group)

            case (.institutions(.onTappedInstitution(let item)), _),
                 (.branches(.onTappedInstitution(let item)), _):
                handleTappedInstitution(state: &state, item: item)

            case (.payment(.delegate(.onBeginPayment)), .useInstitution(let institution)):
                handleBeginPaymentWithInstitution(state: &state, institution: institution)

            case (.payment(.delegate(.onAccountIdentifiersRequired(let institutionItem))), _):
                handleAccountIdentifiersRequired(state: &state, institutionItem: institutionItem)

            case (.payment(.delegate(.onUpdatedPayment(let identifier))), _):
                handleUpdatedPayment(state: &state, identifier: identifier)

            case (.payment(.delegate(.onSelectAnotherBank)), _):
                handleSelectAnotherBank(state: &state)

            case (.accountIdentifiers(.delegate(.onSubmitted(let accountIdentifiersData))), _):
                handleAccountIdentifiersSubmitted(state: &state, accountIdentifiersData: accountIdentifiersData)

            case (.payment(.delegate(.onReturnToMerchant)), _),
                 (.accountIdentifiers(.delegate(.onReturnToMerchant)), _),
                 (.educational(.navBar(.delegate(.onSubmitFeedback))), _),
                 (.institutions(.navBar(.delegate(.onSubmitFeedback))), _),
                 (.branches(.navBar(.delegate(.onSubmitFeedback))), _):
                handleReturnToMerchant(state: state)

            default:
                .none
            }
        }
        .forEach(\.path, action: \.view.path)
    }

    // MARK: - Internal Actions

    private func handleEducationalContinueWithDefaultCountry(
        state: inout State,
        defaultCountry: Country
    ) -> Effect<Action> {
        state.selectedCountry = defaultCountry
        state.path.append(.institutions(.init(
            currency: state.intent.amount.currency,
            defaultCountry: defaultCountry
        )))
        return .none
    }

    private func handleEducationalContinue(state: inout State) -> Effect<Action> {
        state.path.append(.institutions(.init(currency: state.intent.amount.currency, defaultCountry: nil)))
        return .none
    }

    private func handleSelectedCountryChanged(state: inout State, selectedCountry: Country) -> Effect<Action> {
        state.selectedCountry = selectedCountry
        return .none
    }

    private func handleTappedGroup(state: inout State, group: Institution.Group) -> Effect<Action> {
        state.path.append(.branches(.init(group: group)))
        return .none
    }

    private func handleTappedInstitution(state: inout State, item: Institution.Item) -> Effect<Action> {
        guard item.isActive else { return .none }

        state.selectedInstitution = item.asInstitution
        state.path.append(.payment(.init(intent: state.intent, institution: item.asInstitution)))
        return .none
    }

    private func handleBeginPaymentWithInstitution(state: inout State, institution: Institution) -> Effect<Action> {
        state.selectedInstitution = institution
        state.selectedCountry = institution.country
        return .none
    }

    private func handleAccountIdentifiersRequired(
        state: inout State,
        institutionItem: Institution.Item
    ) -> Effect<Action> {
        guard let selectedCountry = state.selectedCountry else { return .none }

        state.path.append(.accountIdentifiers(.init(institution: institutionItem, country: selectedCountry)))
        return .none
    }

    private func handleUpdatedPayment(state: inout State, identifier: PaymentIdentifier) -> Effect<Action> {
        state.paymentIdentifier = identifier
        return .none
    }

    private func handleSelectAnotherBank(state: inout State) -> Effect<Action> {
        _ = state.path.popLast()
        return .none
    }

    private func handleAccountIdentifiersSubmitted(
        state: inout State,
        accountIdentifiersData: AccountIdentifiersData
    ) -> Effect<Action> {
        _ = state.path.popLast()

        guard let id = state.path.ids.last else { return .none }

        return .send(.view(.path(.element(id: id, action:
                .payment(.delegate(.onReceivedAccountIdentifiersData(accountIdentifiersData)))))))
    }

    private func handleReturnToMerchant(state: State) -> Effect<Action> {
        checkoutResult.yieldResult(checkoutResult(for: state))
        return .run { _ in await dismiss(animation: .default) }
    }

    // MARK: - Helpers

    private func checkoutResult(for state: State) -> CheckoutResult? {
        guard let payment = state.paymentIdentifier, let institution = state.selectedInstitution else {
            return nil
        }
        return .paymentCreated(id: payment.id, status: .init(payment.status), institution: institution)
    }
}

extension PaymentFlowFeature.Path.State: Equatable {}
