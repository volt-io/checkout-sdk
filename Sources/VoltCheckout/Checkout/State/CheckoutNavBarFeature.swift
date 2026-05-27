//
// CheckoutNavBarFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 09/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CheckoutNavBarFeature {
    @ObservableState
    struct State: Equatable {
        var hidesBackButton: Bool
        var feedbackProvider: AnyFeedbackProvider
        @Presents var feedback: FeedbackFeature.State?
    }

    enum Action: FeatureAction {
        @CasePathable
        enum ViewAction {
            case onCloseButtonTapped
        }

        @CasePathable
        enum DelegateAction {
            case onSubmitFeedback
            case onDismissFeedback
        }

        @CasePathable
        enum InternalAction {
            case feedback(PresentationAction<FeedbackFeature.Action>)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case _internal(InternalAction)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onCloseButtonTapped):
                state.feedback = FeedbackFeature.State(
                    context: state.feedbackProvider.context,
                    options: state.feedbackProvider.options
                )
                return .none
            case .delegate:
                return .none
            case ._internal(.feedback(.presented(.delegate(.onSubmit)))):
                return .send(.delegate(.onSubmitFeedback))
            case ._internal(.feedback(.dismiss)):
                return .send(.delegate(.onDismissFeedback))
            case ._internal:
                return .none
            }
        }
        .ifLet(\.$feedback, action: \._internal.feedback) {
            FeedbackFeature()
        }
    }
}

extension CheckoutNavBarFeature.State {
    static func backButtonHidden(with feedbackProvider: any FeedbackProvider) -> Self {
        .init(hidesBackButton: true, feedbackProvider: AnyFeedbackProvider(feedbackProvider))
    }

    static func backButtonVisible(with feedbackProvider: any FeedbackProvider) -> Self {
        .init(hidesBackButton: false, feedbackProvider: AnyFeedbackProvider(feedbackProvider))
    }
}
