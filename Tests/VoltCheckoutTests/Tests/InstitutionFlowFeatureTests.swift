//
// InstitutionFlowFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 05/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import Foundation
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Institution Flow Feature Tests")
@MainActor struct InstitutionFlowFeatureTests {
    let currency = Currency.EUR
    let country = Country(.germany)
    let item = Institution.Item(
        id: "test-id-1",
        name: "Test Institution",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: nil,
        country: Country(.germany),
        isActive: true,
        accountIdentifiers: [],
    )
    let group = Institution.Group(
        name: "Test Group",
        branches: [
            Institution.Item(
                id: "test-id-2",
                name: "Branch 1",
                alternativeName: nil,
                groupName: nil,
                branchName: nil,
                logo: nil,
                country: Country(.germany),
                isActive: true,
                accountIdentifiers: [],
            )
        ]
    )

    @Test("When continue action comes with country hint, then institutions are appended to path with default country")
    func testContinueButtonActionWithHints() async throws {
        let testState = InstitutionFlowFeature.State(
            currency: currency,
            hints: .useDefaultCountry(country),
            path: .init([.educational(.init())])
        )
        let testStore = TestStore(initialState: testState) {
            InstitutionFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].educational.onContinueButtonTapped) {
            $0.path[id: 1] = .institutions(.init(currency: currency, defaultCountry: country))
        }
        await testStore.finish()
    }

    @Test("When continue action comes without hints, then institutions are appended to path without default country")
    func testContinueButtonActionWithoutHints() async throws {
        let testState = InstitutionFlowFeature.State(
            currency: currency,
            hints: .none,
            path: .init([.educational(.init())])
        )
        let testStore = TestStore(initialState: testState) {
            InstitutionFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].educational.onContinueButtonTapped) {
            $0.path[id: 1] = .institutions(.init(currency: currency, defaultCountry: nil))
        }
        await testStore.finish()
    }

    @Test("When tap on group action comes, then branches feature is appended to path")
    func testOnTapGroupAction() async throws {
        let testState = InstitutionFlowFeature.State(
            currency: currency,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            InstitutionFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].institutions.onTappedGroup, group) {
            $0.path[id: 1] = .branches(.init(group: group))
        }
        await testStore.finish()
    }

    @Test("When tap on institution action comes, then it yields result with institution and dismiss action is sent")
    func testOnInstitutionAction() async throws {
        var isDismissed = false
        let expectedResult = CheckoutResult.institutionSelected(institution: item.asInstitution)
        let testState = InstitutionFlowFeature.State(
            currency: currency,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            InstitutionFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == expectedResult)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].institutions.onTappedInstitution, item)

        #expect(isDismissed == true)
    }

    @Test("When feedback sheet is submitted, then it yields nil result and dismiss action is sent")
    func testFeedbackSheetSubmit() async throws {
        var isDismissed = false
        let testState = InstitutionFlowFeature.State(
            currency: currency,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            InstitutionFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == nil)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].institutions.navBar.view.onCloseButtonTapped)
        await testStore.send(\.view.path[id: 0].institutions.navBar.delegate.onSubmitFeedback)

        #expect(isDismissed == true)
    }

}
