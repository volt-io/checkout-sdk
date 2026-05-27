//
// CheckoutNavBarFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 30/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Checkout Nav Bar Feature Tests")
@MainActor struct CheckoutNavBarFeatureTests {
    let feedbackProvider = EducationalFeedback()

    var initialState: CheckoutNavBarFeature.State {
        .backButtonHidden(with: feedbackProvider)
    }

    @Test("When state is created with backButtonHidden helper, then hidesBackButton is true")
    func testBackButtonHiddenState() {
        let state = CheckoutNavBarFeature.State.backButtonHidden(with: feedbackProvider)
        #expect(state.hidesBackButton == true)
        #expect(state.feedback == nil)
    }

    @Test("When state is created with backButtonVisible helper, then hidesBackButton is false")
    func testBackButtonVisibleState() {
        let state = CheckoutNavBarFeature.State.backButtonVisible(with: feedbackProvider)
        #expect(state.hidesBackButton == false)
        #expect(state.feedback == nil)
    }

    @Test("When close button is tapped, then feedback sheet is presented with provider's context and options")
    func testOnCloseButtonTapped() async throws {
        let testStore = TestStore(initialState: initialState) {
            CheckoutNavBarFeature()
        }

        await testStore.send(.view(.onCloseButtonTapped)) {
            $0.feedback = FeedbackFeature.State(
                context: self.feedbackProvider.context,
                options: self.feedbackProvider.options
            )
        }
        await testStore.finish()
    }

    @Test("When feedback is submitted, then onSubmitFeedback delegate action is sent and sheet is dismissed")
    func testFeedbackSubmit() async throws {
        var state = initialState
        state.feedback = FeedbackFeature.State(
            context: feedbackProvider.context,
            options: feedbackProvider.options
        )
        let testStore = TestStore(initialState: state) {
            CheckoutNavBarFeature()
        }
        testStore.exhaustivity = .off

        await testStore.send(._internal(.feedback(.presented(.view(.onSubmitButtonTapped)))))
        await testStore.receive(\._internal.feedback.presented.delegate.onSubmit)
        await testStore.receive(\.delegate.onSubmitFeedback)
        await testStore.finish()
    }

    @Test("When feedback sheet is dismissed, then onDismissFeedback delegate action is sent")
    func testFeedbackDismiss() async throws {
        var state = initialState
        state.feedback = FeedbackFeature.State(
            context: feedbackProvider.context,
            options: feedbackProvider.options
        )
        let testStore = TestStore(initialState: state) {
            CheckoutNavBarFeature()
        }

        await testStore.send(._internal(.feedback(.dismiss))) {
            $0.feedback = nil
        }
        await testStore.receive(\.delegate.onDismissFeedback)
        await testStore.finish()
    }
}
