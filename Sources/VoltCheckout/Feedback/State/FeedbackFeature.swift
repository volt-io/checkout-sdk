//
// FeedbackFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct FeedbackFeature {
    @ObservableState
    struct State: Equatable {
        let context: FeedbackContext
        let options: [FeedbackOption]

        var selectedOption: FeedbackOption?
        var selectedOptionValue: String? {
            selectedOption?.rawValue
        }
    }

    enum Action: FeatureAction {
        @CasePathable
        enum ViewAction {
            case onAppear
            case onSelectedFeedbackOption(String?)
            case onSubmitButtonTapped
        }

        @CasePathable
        enum DelegateAction {
            case onSubmit
        }

        enum InternalAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case _internal(InternalAction)
    }

    @Dependency(\.analytics.track) var track

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .none
            case .view(.onSelectedFeedbackOption(let optionValue)):
                if let optionValue {
                    state.selectedOption = FeedbackOption(rawValue: optionValue)
                } else {
                    state.selectedOption = nil
                }
                return .none
            case .view(.onSubmitButtonTapped):
                track(.cancellationConfirmed, [
                    .feedback: state.selectedOption?.key,
                    .cancelledScreen: state.context.rawValue,
                ])
                return .send(.delegate(.onSubmit))
            case .delegate:
                return .none
            }
        }
    }
}
