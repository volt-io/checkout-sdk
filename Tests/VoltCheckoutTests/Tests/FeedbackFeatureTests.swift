//
// FeedbackFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 19/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Feedback Feature Tests")
@MainActor struct FeedbackFeatureTests {
    let feedbackProvider = EducationalFeedback()
    let initialState: FeedbackFeature.State

    init() {
        self.initialState = FeedbackFeature.State(
            context: feedbackProvider.context,
            options: feedbackProvider.options
        )
    }

    @Test("When feedback appears, then nothing happens")
    func testOnAppear() async throws {
        let testStore = TestStore(initialState: initialState) {
            FeedbackFeature()
        }

        await testStore.send(.view(.onAppear))
        await testStore.finish()
    }

    @Test("When select option action is received, then selected option changes accordingly")
    func testSelectFeedbackOption() async throws {
        let testStore = TestStore(initialState: initialState) {
            FeedbackFeature()
        }
        let option = feedbackProvider.options[0]

        await testStore.send(.view(.onSelectedFeedbackOption(option.rawValue))) {
            $0.selectedOption = option
        }
        await testStore.send(.view(.onSelectedFeedbackOption(nil))) {
            $0.selectedOption = nil
        }
    }

    @Test("When feedback is submitted, then analytics event with correct values is tracked")
    func testOnSubmitFeedback() async throws {
        let expectedOption = feedbackProvider.options[0]
        let testStore = TestStore(initialState: initialState) {
            FeedbackFeature()
        } withDependencies: {
            $0.analytics.track = { name, properties in
                #expect(name == .cancellationConfirmed)
                #expect(properties[.feedback] == expectedOption.key)
                #expect(properties[.cancelledScreen] == feedbackProvider.context.rawValue)
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(.view(.onSelectedFeedbackOption(expectedOption.rawValue)))
        await testStore.send(.view(.onSubmitButtonTapped))
    }
}
