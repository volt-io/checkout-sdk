//
// EducationalFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 17/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Educational Feature Tests")
@MainActor struct EducationalFeatureTests {
    let initialState: EducationalFeature.State

    init() {
        self.initialState = EducationalFeature.State()
    }

    @Test("When various actions are sent, then respective tracking events are sent", arguments: zip(
        [EducationalFeature.Action.onAppear, .onContinueButtonTapped, .onTermsAndConditionsTapped],
        [Event.Name.openBankingPage, .continueOnWelcomeView, .openTermsAndConditions]
    ))
    func testAnalytics(action: EducationalFeature.Action, expectedEvent: Event.Name) async throws {
        let testStore = TestStore(initialState: initialState) {
            EducationalFeature()
        } withDependencies: {
            $0.analytics.track = { name, _ in
                #expect(name == expectedEvent)
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(action)
    }
}
