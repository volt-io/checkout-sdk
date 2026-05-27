//
// AccountIdentifiersFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 30/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Account Identifiers Feature Tests")
@MainActor struct AccountIdentifiersFeatureTests {
    let institutionWithIBAN = Institution.Item(
        id: "test-id-iban",
        name: "Test Institution IBAN",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: nil,
        country: Country(.germany),
        isActive: true,
        accountIdentifiers: [.IBAN],
    )
    let institutionWithMultipleIdentifiers = Institution.Item(
        id: "test-id-multi",
        name: "Test Institution Multi",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: nil,
        country: Country(.germany),
        isActive: true,
        accountIdentifiers: [.IBAN, .PSUId],
    )
    let institutionWithNoIdentifiers = Institution.Item(
        id: "test-id-none",
        name: "Test Institution None",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: nil,
        country: Country(.germany),
        isActive: true,
        accountIdentifiers: [],
    )
    let testIBAN: IBAN = "DE89370400440532013000"
    let testCountry = Country(.germany)

    @Test("When feature is initialized with institution, then data is populated from account identifiers")
    func testInitialState() async throws {
        let state = AccountIdentifiersFeature.State(institution: institutionWithIBAN, country: testCountry)

        #expect(state.institution == institutionWithIBAN)
        #expect(state.data.IBAN == "")
        #expect(state.data.PSUId == nil)
        #expect(state.data.branchCode == nil)
        #expect(state.data.accountNumber == nil)
    }

    @Test("When feature is initialized with institution requiring multiple identifiers, then data is populated for each")
    func testInitialStateMultipleIdentifiers() async throws {
        let state = AccountIdentifiersFeature.State(institution: institutionWithMultipleIdentifiers, country: testCountry)

        #expect(state.data.IBAN == "")
        #expect(state.data.PSUId == "")
        #expect(state.data.branchCode == nil)
        #expect(state.data.accountNumber == nil)
    }

    @Test("When onAppear is sent, then no state changes occur")
    func testOnAppear() async throws {
        let testStore = TestStore(initialState: AccountIdentifiersFeature.State(institution: institutionWithIBAN, country: testCountry)) {
            AccountIdentifiersFeature()
        }

        await testStore.send(.view(.onAppear))
        await testStore.finish()
    }

    @Test("When continue button is tapped, then submitted delegate action is sent with current data")
    func testOnContinueButtonTapped() async throws {
        var initialState = AccountIdentifiersFeature.State(institution: institutionWithIBAN, country: testCountry)
        initialState.data.IBAN = testIBAN
        let expectedData = AccountIdentifiersData(IBAN: testIBAN)

        let testStore = TestStore(initialState: initialState) {
            AccountIdentifiersFeature()
        }
        testStore.exhaustivity = .off

        await testStore.send(.view(.onContinueButtonTapped))
        await testStore.receive(\.delegate.onSubmitted, expectedData)

        #expect(testStore.state.data == expectedData)
    }

    @Test("When nav bar delegate sends onSubmitFeedback, then return to merchant delegate action is sent")
    func testNavBarFeedbackSubmitTriggersReturnToMerchant() async throws {
        let testStore = TestStore(initialState: AccountIdentifiersFeature.State(institution: institutionWithIBAN, country: testCountry)) {
            AccountIdentifiersFeature()
        }

        await testStore.send(._internal(.navBar(.delegate(.onSubmitFeedback))))
        await testStore.receive(\.delegate.onReturnToMerchant)
        await testStore.finish()
    }

    @Test("When close button is tapped on nav bar, then feedback sheet is presented")
    func testNavBarCloseButtonShowsFeedback() async throws {
        let feedbackProvider = AccountIdentifiersFeedback()
        let testStore = TestStore(initialState: AccountIdentifiersFeature.State(institution: institutionWithIBAN, country: testCountry)) {
            AccountIdentifiersFeature()
        }

        await testStore.send(._internal(.navBar(.view(.onCloseButtonTapped)))) {
            $0.navBar.feedback = FeedbackFeature.State(
                context: feedbackProvider.context,
                options: feedbackProvider.options
            )
        }
        await testStore.finish()
    }
}
