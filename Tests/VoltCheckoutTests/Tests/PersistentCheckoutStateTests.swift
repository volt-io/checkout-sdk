//
// PersistentCheckoutStateTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 19/05/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Persistent Checkout State Tests")
struct PersistentCheckoutStateTests {
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

    @Test("Returns nil when flow state is nil")
    func testNilFlowReturnsNil() {
        #expect(PersistentCheckoutState(with: nil) == nil)
        #expect(PersistentCheckoutState(with: nil, skipEducational: true) == nil)
    }

    @Test("Institution flow with educational in path stores skipEducational as true")
    func testInstitutionFlowEducationalInPath() {
        var flowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        flowState.path[id: 0] = .educational(.init())

        let state = PersistentCheckoutState(with: .institution(flowState))

        #expect(state?.skipEducational == true)
        #expect(state?.flow == .institution(currency, .none))
    }

    @Test("Institution flow without educational in path stores skipEducational as false")
    func testInstitutionFlowNoEducationalInPath() {
        var flowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        flowState.path[id: 0] = .institutions(.init(currency: currency, defaultCountry: nil))

        let state = PersistentCheckoutState(with: .institution(flowState))

        #expect(state?.skipEducational == false)
    }

    @Test("Institution flow without educational in path preserves skipEducational=true from parameter")
    func testInstitutionFlowPreservesSkipEducationalFromParameter() {
        var flowState = InstitutionFlowFeature.State(currency: currency, hints: .none)
        flowState.path[id: 0] = .institutions(.init(currency: currency, defaultCountry: nil))

        let state = PersistentCheckoutState(with: .institution(flowState), skipEducational: true)

        #expect(state?.skipEducational == true)
    }

    @Test("Institution flow stores currency and hints")
    func testInstitutionFlowStoresCurrencyAndHints() {
        let flowState = InstitutionFlowFeature.State(currency: currency, hints: .useDefaultCountry(country))

        let state = PersistentCheckoutState(with: .institution(flowState))

        #expect(state?.flow == .institution(currency, .useDefaultCountry(country)))
    }

    @Test("Payment flow with educational in path stores skipEducational as true")
    func testPaymentFlowEducationalInPath() {
        var flowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        flowState.path[id: 0] = .educational(.init())

        let state = PersistentCheckoutState(with: .payment(flowState))

        #expect(state?.skipEducational == true)
    }

    @Test("Payment flow without educational in path stores skipEducational as false")
    func testPaymentFlowNoEducationalInPath() {
        var flowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        flowState.path[id: 0] = .institutions(.init(currency: currency, defaultCountry: nil))

        let state = PersistentCheckoutState(with: .payment(flowState))

        #expect(state?.skipEducational == false)
    }

    @Test("Payment flow without educational in path preserves skipEducational=true from parameter")
    func testPaymentFlowPreservesSkipEducationalFromParameter() {
        var flowState = PaymentFlowFeature.State(intent: intent, hints: .none)
        flowState.path[id: 0] = .institutions(.init(currency: currency, defaultCountry: nil))

        let state = PersistentCheckoutState(with: .payment(flowState), skipEducational: true)

        #expect(state?.skipEducational == true)
    }

    @Test("Payment flow stores intent, hints, selected institution and payment identifier")
    func testPaymentFlowStoresData() {
        let identifier = PaymentIdentifier(id: "payment-id", token: "token", status: .newPayment)
        let flowState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            selectedInstitution: institution,
            selectedCountry: institution.country,
            paymentIdentifier: identifier
        )

        let state = PersistentCheckoutState(with: .payment(flowState))

        #expect(state?.flow == .payment(intent, .none, institution, identifier))
    }

    @Test("Payment flow without institution stores nil institution")
    func testPaymentFlowNoInstitution() {
        let flowState = PaymentFlowFeature.State(intent: intent, hints: .none)

        let state = PersistentCheckoutState(with: .payment(flowState))

        #expect(state?.flow == .payment(intent, .none, nil, nil))
    }
}
