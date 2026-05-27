//
// CheckoutRootFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct CheckoutRootFeature {
    @Reducer
    enum Flow {
        case institution(InstitutionFlowFeature)
        case payment(PaymentFlowFeature)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var flow: Flow.State?
        @Shared(.fileStorage(.persistedStateURL)) var persistedState: PersistentCheckoutState?
        var skipEducational: Bool { persistedState?.skipEducational ?? false }
    }

    @CasePathable
    enum Action: FeatureAction {
        @CasePathable
        enum ViewAction {
            case onAppear
            case onScenePhaseChange(ScenePhase)
            case flow(PresentationAction<Flow.Action>)
        }

        @CasePathable
        enum DelegateAction {
            case onBeginInstitutionFlow(Currency, CheckoutHints)
            case onBeginPaymentFlow(PaymentIntent, CheckoutHints)
            case onResumePaymentFlow(PaymentIntent, Institution, PaymentIdentifier?)
        }

        @CasePathable
        enum InternalAction {
            case presentFlow(Flow.State)
            case restoreFlowIfAvailable
            case saveFlowState
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case _internal(InternalAction)
    }

    @Dependency(\.checkoutRouting) var routing

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                handleOnAppear()
            case let .view(.onScenePhaseChange(scenePhase)):
                handleOnScenePhaseChange(scenePhase)
            case .view(.flow):
                handleFlowAction()
            case let .delegate(.onBeginInstitutionFlow(currency, hints)):
                handleOnBeginInstitutionFlow(with: state, currency: currency, hints: hints)
            case let .delegate(.onBeginPaymentFlow(intent, hints)):
                handleOnBeginPaymentFlow(with: state, intent: intent, hints: hints)
            case let .delegate(.onResumePaymentFlow(intent, institution, identifier)):
                handleOnResumePaymentFlow(with: state, intent: intent, institution: institution, identifier: identifier)
            case let ._internal(.presentFlow(flowState)):
                handlePresentFlow(with: &state, flowState: flowState)
            case ._internal(.restoreFlowIfAvailable):
                handleRestoreFlowIfAvailable(with: &state)
            case ._internal(.saveFlowState):
                handleSaveFlowState(with: state)
            }
        }
        .ifLet(\.$flow, action: \.view.flow)
    }

    // MARK: - View Actions

    func handleOnAppear() -> Effect<Action> {
        .send(._internal(.restoreFlowIfAvailable))
    }

    func handleOnScenePhaseChange(_ scenePhase: ScenePhase) -> Effect<Action> {
        guard scenePhase == .background else { return .none }
        return .send(._internal(.saveFlowState))
    }

    func handleFlowAction() -> Effect<Action> {
        .send(._internal(.saveFlowState))
    }

    // MARK: - Delegate Actions

    func handleOnBeginInstitutionFlow(with state: State, currency: Currency, hints: CheckoutHints) -> Effect<Action> {
        guard state.flow == nil else { return .none }

        var flowState = InstitutionFlowFeature.State(currency: currency, hints: hints)
        flowState.path.append(contentsOf: routing.institutionFlowPath(currency, hints, state.skipEducational))
        return .send(._internal(.presentFlow(.institution(flowState))))
    }

    func handleOnBeginPaymentFlow(with state: State, intent: PaymentIntent, hints: CheckoutHints) -> Effect<Action> {
        guard state.flow == nil else { return .none }

        var flowState = PaymentFlowFeature.State(intent: intent, hints: hints)
        flowState.path.append(contentsOf: routing.paymentFlowPath(intent, hints, state.skipEducational))
        return .send(._internal(.presentFlow(.payment(flowState))))
    }

    func handleOnResumePaymentFlow(
        with state: State,
        intent: PaymentIntent,
        institution: Institution,
        identifier: PaymentIdentifier?
    ) -> Effect<Action> {
        guard state.flow == nil else { return .none }

        var flowState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            selectedInstitution: institution,
            selectedCountry: institution.country,
            paymentIdentifier: identifier
        )
        flowState.path.append(contentsOf: routing.resumedPaymentFlowPath(
            intent: intent,
            institution: institution,
            identifier: identifier
        ))
        return .send(._internal(.presentFlow(.payment(flowState))))
    }

    // MARK: - Internal Actions

    func handlePresentFlow(with state: inout State, flowState: Flow.State) -> Effect<Action> {
        state.flow = flowState
        return .none
    }

    func handleRestoreFlowIfAvailable(with state: inout State) -> Effect<Action> {
        guard let persistedState = state.persistedState else { return .none }

        switch persistedState.flow {
        case let .institution(currency, hints):
            return .send(.delegate(.onBeginInstitutionFlow(currency, hints)))
        case let .payment(intent, _, institution?, identifier):
            return .send(.delegate(.onResumePaymentFlow(intent, institution, identifier)))
        case let .payment(intent, hints, _, _):
            return .send(.delegate(.onBeginPaymentFlow(intent, hints)))
        }
    }

    func handleSaveFlowState(with state: State) -> Effect<Action> {
        state.$persistedState.withLock {
            $0 = PersistentCheckoutState(with: state.flow, skipEducational: state.skipEducational)
        }
        return .none
    }
}

extension CheckoutRootFeature.Flow.State: Equatable {}

extension URL {
    static let persistedStateURL = Self.temporaryDirectory.appending(component: "volt-checkout-persisted-state.json")
}
