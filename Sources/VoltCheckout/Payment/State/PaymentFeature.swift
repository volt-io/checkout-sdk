//
// PaymentFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 19/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct PaymentFeature {
    @ObservableState
    struct State: Equatable {
        let intent: PaymentIntent
        let institution: Institution
        var identifier: PaymentIdentifier?

        var progressState: PaymentProgressState = .verifying
        var isFeedbackSheetPresented: Bool { navBar.feedback != nil }
        var isCancellationPossible: Bool
        var navBar: CheckoutNavBarFeature.State = .backButtonHidden(with: PaymentFeedback())

        init(intent: PaymentIntent, institution: Institution, identifier: PaymentIdentifier? = nil) {
            self.intent = intent
            self.institution = institution
            self.isCancellationPossible = identifier == nil
            self.identifier = identifier
            self.navBar = .backButtonHidden(with: PaymentFeedback())
        }
    }

    enum Action: FeatureAction {
        enum ViewAction {
            case onAppear
            case onScenePhaseChange(ScenePhase)
            case onSelectAnotherBankTapped
            case onReturnToMerchantTapped
        }

        @CasePathable
        enum DelegateAction {
            case onBeginPayment
            case onAccountIdentifiersRequired(Institution.Item)
            case onReceivedAccountIdentifiersData(AccountIdentifiersData)
            case onUpdatedPayment(PaymentIdentifier)
            case onSelectAnotherBank
            case onReturnToMerchant
        }

        @CasePathable
        enum InternalAction {
            case verifyInstitution
            case createPayment(AccountIdentifiersData)
            case createdPayment(PaymentIdentifier)
            case startStatusPolling(PaymentIdentifier)
            case updatedPayment(GetPaymentStatusUseCase.Update)
            case openRedirect(URL)
            case paymentFailed(PaymentError)
            case cancelPaymentIfPossible
            case navBar(CheckoutNavBarFeature.Action)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case _internal(InternalAction)
    }

    private enum CancelID {
        case createPayment, statusPolling, awaitingRedirect
    }
    
    @Dependency(\.logger[subsystem: "VoltCheckout", category: "PaymentFeature"]) var logger
    @Dependency(\.verifyInstitution.verify) var verifyInstitution
    @Dependency(\.createPayment.create) var createPayment
    @Dependency(\.paymentStatus.status) var paymentStatus
    @Dependency(\.voltAPI.cancelPayment) var cancelPayment
    @Dependency(\.analytics.track) var track
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.openURL) var openURL

    var body: some ReducerOf<Self> {
        Scope(state: \.navBar, action: \._internal.navBar) {
            CheckoutNavBarFeature()
        }
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                handleOnAppear(with: state)
            case .view(.onScenePhaseChange(let scenePhase)):
                handleOnScenePhaseChange(with: state, scenePhase)
            case .view(.onSelectAnotherBankTapped):
                handleOnSelectAnotherBankTapped(with: state)
            case .view(.onReturnToMerchantTapped):
                handleOnReturnToMerchantTapped(with: state)
            case .delegate(.onAccountIdentifiersRequired):
                handleOnAccountIdentifiersRequired(with: &state)
            case .delegate(.onReceivedAccountIdentifiersData(let accountIdentifiersData)):
                handleOnReceivedAccountIdentifiersData(with: accountIdentifiersData)
            case ._internal(.verifyInstitution):
                handleVerifyInstitution(with: state)
            case ._internal(.createPayment(let accountIdentifiersData)):
                handleCreatePayment(with: state, accountIdentifiersData)
            case ._internal(.createdPayment(let identifier)):
                handleCreatedPayment(with: &state, identifier: identifier)
            case ._internal(.startStatusPolling(let identifier)):
                handleStartStatusPolling(with: identifier)
            case ._internal(.updatedPayment(let update)):
                handleUpdatedPayment(with: &state, update)
            case ._internal(.openRedirect(let url)):
                handleReceivedRedirect(with: url)
            case ._internal(.paymentFailed(let paymentError)):
                handlePaymentFailed(with: &state, error: paymentError)
            case ._internal(.cancelPaymentIfPossible):
                handleCancelPaymentIfPossible(with: &state)
            case ._internal(.navBar(.delegate(.onDismissFeedback))):
                handleOnDismissFeedback(with: state)
            case ._internal(.navBar(.delegate(.onSubmitFeedback))):
                handleOnSubmitFeedback()
            case .delegate, ._internal(.navBar):
                .none
            }
        }
    }

    // MARK: - View Actions

    func handleOnAppear(with state: State) -> Effect<Action> {
        guard state.progressState == .verifying, state.identifier == nil else { return .none }

        return .concatenate(
            .send(.delegate(.onBeginPayment)),
            .send(._internal(.verifyInstitution))
        )
    }

    func handleOnScenePhaseChange(with state: State, _ scenePhase: ScenePhase) -> Effect<Action> {
        guard scenePhase == .active, let identifier = state.identifier else { return .none }

        return .send(._internal(.startStatusPolling(identifier)))
    }

    func handleOnSelectAnotherBankTapped(with _: State) -> Effect<Action> {
        track(.placeholderEvent, [:])

        return .concatenate(
            .send(._internal(.cancelPaymentIfPossible)),
            .send(.delegate(.onSelectAnotherBank))
        )
    }

    func handleOnReturnToMerchantTapped(with _: State) -> Effect<Action> {
        track(.placeholderEvent, [:])

        return .concatenate(
            .send(._internal(.cancelPaymentIfPossible)),
            .send(.delegate(.onReturnToMerchant))
        )
    }

    // MARK: - Delegate Actions

    func handleOnAccountIdentifiersRequired(with state: inout State) -> Effect<Action> {
        state.progressState = .collectingAccountIdentifiers
        
        return .none
    }

    func handleOnReceivedAccountIdentifiersData(with accountIdentifiersData: AccountIdentifiersData) -> Effect<Action> {
        .send(._internal(.createPayment(accountIdentifiersData)))
    }

    // MARK: - Internal Actions

    func handleVerifyInstitution(with state: State) -> Effect<Action> {
        .run { [institution = state.institution] send in
            let institutionItem = try await verifyInstitution(institution)

            if institutionItem.accountIdentifiers.isEmpty {
                await send(._internal(.createPayment(AccountIdentifiersData())))
            } else {
                await send(.delegate(.onAccountIdentifiersRequired(institutionItem)))
            }
        } catch: { error, send in
            let paymentError = error as? PaymentError ?? PaymentError.unknown(error)
            await send(._internal(.paymentFailed(paymentError)), animation: .default)
        }
    }

    func handleCreatePayment(with state: State, _ accountIdentifiersData: AccountIdentifiersData) -> Effect<Action> {
        .run { send in
            let identifier = try await createPayment(state.intent, state.institution, accountIdentifiersData)
            await send(._internal(.createdPayment(identifier)), animation: .default)
        } catch: { error, send in
            let paymentError = error as? PaymentError ?? PaymentError.unknown(error)
            await send(._internal(.paymentFailed(paymentError)), animation: .default)
        }
        .cancellable(id: CancelID.createPayment)
    }

    func handleCreatedPayment(with state: inout State, identifier: PaymentIdentifier) -> Effect<Action> {
        state.progressState = .processing(provider: nil)
        state.identifier = identifier

        return .concatenate(
            .send(.delegate(.onUpdatedPayment(identifier))),
            .send(._internal(.startStatusPolling(identifier)), animation: .default)
        )
    }

    func handleStartStatusPolling(with identifier: PaymentIdentifier) -> Effect<Action> {
        .run { send in
            for try await update in paymentStatus(identifier) {
                await send(._internal(.updatedPayment(update)), animation: .default)
            }
        } catch: { error, send in
            let paymentError = error as? PaymentError ?? PaymentError.unknown(error)
            await send(._internal(.paymentFailed(paymentError)), animation: .default)
        }
        .cancellable(id: CancelID.statusPolling)
    }

    func handleUpdatedPayment(with state: inout State, _ update: GetPaymentStatusUseCase.Update) -> Effect<Action> {
        state.identifier = update.paymentIdentifier
        state.progressState = update.progressState

        var nextAction: Effect<Action> = .none

        if case .failed(let paymentError) = update.progressState {
            nextAction = .send(._internal(.paymentFailed(paymentError)))
        }

        if case .awaitingRedirect(let url) = update.progressState, !state.isFeedbackSheetPresented {
            nextAction = .send(._internal(.openRedirect(url)))
        }

        return .concatenate(.send(.delegate(.onUpdatedPayment(update.paymentIdentifier))), nextAction)
    }

    func handleReceivedRedirect(with url: URL) -> Effect<Action> {
        .run { _ in await openURL(url) }
    }

    func handlePaymentFailed(with state: inout State, error: PaymentError) -> Effect<Action> {
        state.progressState = .failed(error: error)
        logger.error("\(error)")

        return .merge(
            .cancel(id: CancelID.createPayment),
            .cancel(id: CancelID.statusPolling),
            .cancel(id: CancelID.awaitingRedirect)
        )
    }

    func handleCancelPaymentIfPossible(with state: inout State) -> Effect<Action> {
        guard state.isCancellationPossible,
              let identifier = state.identifier,
              identifier.status != .delayedAtBank
        else {
            return .merge(
                .cancel(id: CancelID.createPayment),
                .cancel(id: CancelID.statusPolling),
                .cancel(id: CancelID.awaitingRedirect)
            )
        }

        return .concatenate(
            .merge(
                .cancel(id: CancelID.createPayment),
                .cancel(id: CancelID.statusPolling),
                .cancel(id: CancelID.awaitingRedirect)
            ),
            .run { _ in
                try await cancelPayment(identifier.id, identifier.token)
            }
        )
    }

    func handleOnDismissFeedback(with state: State) -> Effect<Action> {
        if case .awaitingRedirect(let url) = state.progressState, !state.isFeedbackSheetPresented {
            return .send(._internal(.openRedirect(url)))
                .debounce(id: CancelID.awaitingRedirect, for: 0.5, scheduler: mainQueue)
        }
        return .none
    }

    func handleOnSubmitFeedback() -> Effect<Action> {
        .concatenate(
            .send(._internal(.cancelPaymentIfPossible)),
            .send(.delegate(.onReturnToMerchant))
        )
    }
}
