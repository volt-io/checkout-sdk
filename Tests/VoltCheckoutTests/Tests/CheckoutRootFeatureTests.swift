//
// CheckoutRootFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 05/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import Foundation
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Checkout Root Feature Tests")
@MainActor struct CheckoutRootFeatureTests {
    let currency = Currency.EUR
    let country = Country(.germany)
    let institution = Institution(
        id: "643df330-d162-4202-a732-784f64ee85c1",
        name: "Berliner Sparkasse",
        logo: URL(string: "https://cdn.volt.io/chk3_banks/logos/xx_sparkasse.svg"),
        country: Country(.germany)
    )
    let intent = PaymentIntent(
        amount: Amount(currency: .EUR, minorUnits: 100)!,
        payer: Payer(
            reference: Payer.Reference("johndoe@example.com")!,
            entity: .person(Payer.Person(firstName: "John", lastName: "Doe")!)
        ),
        transactionType: .goods
    )

    @Test("When begin institution flow action is sent, then action to present this flow is received")
    func testBeginInstitutionFlow() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) {
            CheckoutRootFeature()
        }
        var expectedFlowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        expectedFlowState.path[id: 0] = .educational(.init())

        await testStore.send(.delegate(.onBeginInstitutionFlow(currency, .none)))
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .institution(expectedFlowState)
        }
    }

    @Test("When begin payment flow action is sent, then action to present this flow is received")
    func testBeginPaymentFlow() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) {
            CheckoutRootFeature()
        }
        var expectedFlowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        expectedFlowState.path[id: 0] = .educational(.init())

        await testStore.send(.delegate(.onBeginPaymentFlow(intent, .none)))
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .payment(expectedFlowState)
        }
    }

    @Test("When flow is already in progress, then it's not possible to start another one")
    func testOnlyOneFlowInProgress() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) {
            CheckoutRootFeature()
        }
        var expectedFlowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        expectedFlowState.path[id: 0] = .educational(.init())

        await testStore.send(.delegate(.onBeginPaymentFlow(intent, .none)))
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .payment(expectedFlowState)
        }
        await testStore.send(.delegate(.onBeginInstitutionFlow(currency, .none)))
        await testStore.send(.delegate(.onBeginPaymentFlow(intent, .none)))
        await testStore.finish()
    }

    @Test("When onAppear is triggered, then restoreFlowIfAvailable is sent")
    func testOnAppear() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) {
            CheckoutRootFeature()
        }

        await testStore.send(.view(.onAppear))
        await testStore.receive(\._internal.restoreFlowIfAvailable)
    }

    @Test("When scene phase changes to background, then saveFlowState is sent")
    func testScenePhaseChangeToBackground() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) {
            CheckoutRootFeature()
        }

        await testStore.send(.view(.onScenePhaseChange(.background)))
        await testStore.receive(\._internal.saveFlowState)
    }

    @Test("When scene phase changes to non-background, then no action is sent")
    func testScenePhaseChangeToActive() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) {
            CheckoutRootFeature()
        }

        await testStore.send(.view(.onScenePhaseChange(.active)))
        await testStore.send(.view(.onScenePhaseChange(.inactive)))
        await testStore.finish()
    }

    @Test("When a flow action is received, then saveFlowState is sent")
    func testFlowActionSavesFlowState() async throws {
        var initialState = CheckoutRootFeature.State()
        var paymentFlowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        paymentFlowState.path[id: 0] = .educational(.init())
        initialState.flow = .payment(paymentFlowState)

        let testStore = TestStore(initialState: initialState) {
            CheckoutRootFeature()
        }

        await testStore.send(.view(.flow(.dismiss))) {
            $0.flow = nil
        }
        await testStore.receive(\._internal.saveFlowState)
    }

    @Test("When resume payment flow action is sent, then payment flow with institution is presented")
    func testResumePaymentFlow() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) {
            CheckoutRootFeature()
        }

        var expectedFlowState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            selectedInstitution: institution,
            selectedCountry: institution.country,
            paymentIdentifier: nil
        )
        expectedFlowState.path[id: 0] = .institutions(.init(
            currency: intent.amount.currency,
            defaultCountry: institution.country,
            selectedCountry: institution.country
        ))
        expectedFlowState.path[id: 1] = .payment(.init(intent: intent, institution: institution))

        await testStore.send(.delegate(.onResumePaymentFlow(intent, institution, nil)))
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .payment(expectedFlowState)
        }
    }

    @Test("When resume payment flow action is sent and flow is already in progress, then nothing happens")
    func testResumePaymentFlowWhenFlowInProgress() async throws {
        var initialState = CheckoutRootFeature.State()
        var existingFlow = PaymentFlowFeature.State(intent: intent, hints: .none)
        existingFlow.path[id: 0] = .educational(.init())
        initialState.flow = .payment(existingFlow)

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        await testStore.send(.delegate(.onResumePaymentFlow(intent, institution, nil)))
        await testStore.finish()
    }

    @Test("When restoreFlowIfAvailable is triggered with no persisted state, then nothing happens")
    func testRestoreFlowIfAvailableNoPersistedState() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) { CheckoutRootFeature() }

        await testStore.send(._internal(.restoreFlowIfAvailable))
        await testStore.finish()
    }

    @Test("When restoreFlowIfAvailable is triggered with institution flow, then institution flow is begun")
    func testRestoreFlowIfAvailableWithInstitutionFlow() async throws {
        let initialState = CheckoutRootFeature.State()
        initialState.$persistedState.withLock {
            $0 = PersistentCheckoutState(flow: .institution(currency, .none), skipEducational: false)
        }
        defer { initialState.$persistedState.withLock { $0 = nil } }

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        var expectedFlowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        expectedFlowState.path[id: 0] = .educational(.init())

        await testStore.send(._internal(.restoreFlowIfAvailable))
        await testStore.receive(\.delegate.onBeginInstitutionFlow)
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .institution(expectedFlowState)
        }
    }

    @Test("When restoreFlowIfAvailable is triggered with payment flow and institution, then payment flow is resumed")
    func testRestoreFlowIfAvailableWithPaymentAndInstitution() async throws {
        let identifier = PaymentIdentifier(id: "payment-id", token: "token", status: .newPayment)
        let initialState = CheckoutRootFeature.State()
        initialState.$persistedState.withLock {
            $0 = PersistentCheckoutState(flow: .payment(intent, .none, institution, identifier), skipEducational: false)
        }
        defer { initialState.$persistedState.withLock { $0 = nil } }

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        var expectedFlowState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            selectedInstitution: institution,
            selectedCountry: institution.country,
            paymentIdentifier: identifier
        )
        expectedFlowState.path[id: 0] = .institutions(.init(
            currency: intent.amount.currency,
            defaultCountry: institution.country,
            selectedCountry: institution.country
        ))
        expectedFlowState.path[id: 1] = .payment(.init(intent: intent, institution: institution, identifier: identifier))

        await testStore.send(._internal(.restoreFlowIfAvailable))
        await testStore.receive(\.delegate.onResumePaymentFlow)
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .payment(expectedFlowState)
        }
    }

    @Test("When restoreFlowIfAvailable is triggered with payment flow and no institution, then payment flow is begun")
    func testRestoreFlowIfAvailableWithPaymentOnly() async throws {
        let initialState = CheckoutRootFeature.State()
        initialState.$persistedState.withLock {
            $0 = PersistentCheckoutState(flow: .payment(intent, .none, nil, nil), skipEducational: false)
        }
        defer { initialState.$persistedState.withLock { $0 = nil } }

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        var expectedFlowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        expectedFlowState.path[id: 0] = .educational(.init())

        await testStore.send(._internal(.restoreFlowIfAvailable))
        await testStore.receive(\.delegate.onBeginPaymentFlow)
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .payment(expectedFlowState)
        }
    }

    @Test("When restoreFlowIfAvailable is triggered with skipEducational=true, flow skips educational")
    func testRestoreFlowSetsSkipEducational() async throws {
        let initialState = CheckoutRootFeature.State()
        initialState.$persistedState.withLock {
            $0 = PersistentCheckoutState(flow: .institution(currency, .none), skipEducational: true)
        }
        defer { initialState.$persistedState.withLock { $0 = nil } }

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        var expectedFlowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        expectedFlowState.path[id: 0] = .institutions(.init(currency: currency, defaultCountry: nil))

        await testStore.send(._internal(.restoreFlowIfAvailable))
        await testStore.receive(\.delegate.onBeginInstitutionFlow)
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .institution(expectedFlowState)
        }
    }

    @Test("When skipEducational is true and begin institution flow is sent, then institutions view is shown directly")
    func testBeginInstitutionFlowSkipEducational() async throws {
        let initialState = CheckoutRootFeature.State()
        initialState.$persistedState.withLock {
            $0 = PersistentCheckoutState(flow: .institution(currency, .none), skipEducational: true)
        }
        defer { initialState.$persistedState.withLock { $0 = nil } }

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        var expectedFlowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        expectedFlowState.path[id: 0] = .institutions(.init(currency: currency, defaultCountry: nil))

        await testStore.send(.delegate(.onBeginInstitutionFlow(currency, .none)))
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .institution(expectedFlowState)
        }
    }

    @Test("When skipEducational is true and begin payment flow is sent, then institutions view is shown directly")
    func testBeginPaymentFlowSkipEducational() async throws {
        let initialState = CheckoutRootFeature.State()
        initialState.$persistedState.withLock {
            $0 = PersistentCheckoutState(flow: .payment(intent, .none, nil, nil), skipEducational: true)
        }
        defer { initialState.$persistedState.withLock { $0 = nil } }

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        var expectedFlowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        expectedFlowState.path[id: 0] = .institutions(.init(currency: intent.amount.currency, defaultCountry: nil))

        await testStore.send(.delegate(.onBeginPaymentFlow(intent, .none)))
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .payment(expectedFlowState)
        }
    }

    @Test("When saveFlowState is triggered after restore with skipEducational=true, then skipEducational is preserved in persisted state")
    func testSaveFlowStatePreservesSkipEducationalAfterRestore() async throws {
        var initialState = CheckoutRootFeature.State()
        initialState.$persistedState.withLock {
            $0 = PersistentCheckoutState(flow: .institution(currency, .none), skipEducational: true)
        }
        var flowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        flowState.path[id: 0] = .institutions(.init(currency: currency, defaultCountry: nil))
        initialState.flow = .institution(flowState)

        let testStore = TestStore(initialState: initialState) { CheckoutRootFeature() }

        await testStore.send(._internal(.saveFlowState))
        await testStore.finish()
    }

    @Test("When institution hint is provided, then payment flow skips educational and shows institution and payment")
    func testBeginPaymentFlowWithInstitutionHint() async throws {
        let testStore = TestStore(initialState: CheckoutRootFeature.State()) { CheckoutRootFeature() }

        var expectedFlowState = PaymentFlowFeature.State(intent: intent, hints: .useInstitution(institution))
        expectedFlowState.path[id: 0] = .institutions(.init(currency: intent.amount.currency, defaultCountry: institution.country))
        expectedFlowState.path[id: 1] = .payment(.init(intent: intent, institution: institution))

        await testStore.send(.delegate(.onBeginPaymentFlow(intent, .useInstitution(institution))))
        await testStore.receive(\._internal.presentFlow) {
            $0.flow = .payment(expectedFlowState)
        }
    }
}
