//
// CheckoutUseCasesTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 05/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Checkout Use Cases Tests")
struct CheckoutUseCasesTests {
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

    @Test("When skipEducational is false, institutionFlowPath returns educational regardless of hints")
    func testInstitutionFlowPathSkipEducationalFalse() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [InstitutionFlowFeature.Path.State] = [.educational(.init())]

        #expect(testUseCase.institutionFlowPath(currency: .RON, hints: .none, skipEducational: false) == expected)
        #expect(testUseCase.institutionFlowPath(currency: .EUR, hints: .none, skipEducational: false) == expected)
        #expect(testUseCase.institutionFlowPath(currency: .EUR, hints: .useDefaultCountry(country), skipEducational: false) == expected)
        #expect(testUseCase.institutionFlowPath(currency: .EUR, hints: .useInstitution(institution), skipEducational: false) == expected)
    }

    @Test("When skipEducational is true with no hints, institutionFlowPath returns institutions without country")
    func testInstitutionFlowPathSkipEducationalTrueNoHints() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [InstitutionFlowFeature.Path.State] = [.institutions(.init(currency: .EUR, defaultCountry: nil))]

        #expect(testUseCase.institutionFlowPath(currency: .EUR, hints: .none, skipEducational: true) == expected)
    }

    @Test("When skipEducational is true with country hint, institutionFlowPath returns institutions with country")
    func testInstitutionFlowPathSkipEducationalTrueCountryHint() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [InstitutionFlowFeature.Path.State] = [.institutions(.init(currency: .EUR, defaultCountry: country))]

        #expect(testUseCase.institutionFlowPath(currency: .EUR, hints: .useDefaultCountry(country), skipEducational: true) == expected)
    }

    @Test("When skipEducational is true with institution hint, institutionFlowPath returns educational")
    func testInstitutionFlowPathSkipEducationalTrueInstitutionHint() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [InstitutionFlowFeature.Path.State] = [.educational(.init())]

        #expect(testUseCase.institutionFlowPath(currency: .EUR, hints: .useInstitution(institution), skipEducational: true) == expected)
    }

    @Test("When hints is useInstitution, paymentFlowPath returns institutions and payment regardless of skipEducational")
    func testPaymentFlowPathWithInstitution() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [PaymentFlowFeature.Path.State] = [
            .institutions(.init(currency: .EUR, defaultCountry: country)),
            .payment(.init(intent: intent, institution: institution))
        ]

        #expect(testUseCase.paymentFlowPath(intent: intent, hints: .useInstitution(institution), skipEducational: false) == expected)
        #expect(testUseCase.paymentFlowPath(intent: intent, hints: .useInstitution(institution), skipEducational: true) == expected)
    }

    @Test("When skipEducational is false, paymentFlowPath returns educational for none and country hints")
    func testPaymentFlowPathSkipEducationalFalse() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [PaymentFlowFeature.Path.State] = [.educational(.init())]

        #expect(testUseCase.paymentFlowPath(intent: intent, hints: .none, skipEducational: false) == expected)
        #expect(testUseCase.paymentFlowPath(intent: intent, hints: .useDefaultCountry(country), skipEducational: false) == expected)
    }

    @Test("When skipEducational is true with no hints, paymentFlowPath returns institutions without country")
    func testPaymentFlowPathSkipEducationalTrueNoHints() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [PaymentFlowFeature.Path.State] = [.institutions(.init(currency: .EUR, defaultCountry: nil))]

        #expect(testUseCase.paymentFlowPath(intent: intent, hints: .none, skipEducational: true) == expected)
    }

    @Test("When skipEducational is true with country hint, paymentFlowPath returns institutions with country")
    func testPaymentFlowPathSkipEducationalTrueCountryHint() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [PaymentFlowFeature.Path.State] = [.institutions(.init(currency: .EUR, defaultCountry: country))]

        #expect(testUseCase.paymentFlowPath(intent: intent, hints: .useDefaultCountry(country), skipEducational: true) == expected)
    }

    @Test("resumedPaymentFlowPath returns institutions with selected country and payment with identifier")
    func testResumedPaymentFlowPathWithIdentifier() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let identifier = PaymentIdentifier(id: "payment-id", token: "token", status: .newPayment)
        let expected: [PaymentFlowFeature.Path.State] = [
            .institutions(.init(currency: .EUR, defaultCountry: country, selectedCountry: country)),
            .payment(.init(intent: intent, institution: institution, identifier: identifier))
        ]

        #expect(testUseCase.resumedPaymentFlowPath(intent: intent, institution: institution, identifier: identifier) == expected)
    }

    @Test("resumedPaymentFlowPath with nil identifier returns institutions and payment without identifier")
    func testResumedPaymentFlowPathNilIdentifier() async throws {
        let testUseCase = CheckoutRoutingUseCase.testValue
        let expected: [PaymentFlowFeature.Path.State] = [
            .institutions(.init(currency: .EUR, defaultCountry: country, selectedCountry: country)),
            .payment(.init(intent: intent, institution: institution, identifier: nil))
        ]

        #expect(testUseCase.resumedPaymentFlowPath(intent: intent, institution: institution, identifier: nil) == expected)
    }
}
