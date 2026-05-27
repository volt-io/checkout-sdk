//
// PaymentIntentBuilderTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/05/2026.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
@testable import VoltCheckout

@Suite("Payment Intent Builder Tests")
struct PaymentIntentBuilderTests {

    @Test("When all required components are provided, then PaymentIntent is created with correct values")
    func testBuildsWithRequiredComponents() {
        let intent = PaymentIntent {
            Amount(currency: .EUR, minorUnits: 100)
            Payer(reference: "john@example.com") {
                Payer.Person(firstName: "John", lastName: "Doe")
            }
            TransactionType.goods
        }

        #expect(intent?.amount.currency == .EUR)
        #expect(intent?.amount.minorUnits == 100)
        #expect(intent?.payer.reference.value == "john@example.com")
        #expect(intent?.transactionType == .goods)
        #expect(intent?.references == nil)
    }

    @Test("When optional references are included, then PaymentIntent carries them")
    func testBuildsWithOptionalReferences() {
        let intent = PaymentIntent {
            Amount(currency: .PLN, minorUnits: 500)
            Payer(reference: "customer-42") {
                Payer.Organization(name: "Acme Corp")
            }
            TransactionType.services
            PaymentReferences(paymentReference: "REF12345", internalReference: "INT-001")
        }

        #expect(intent?.references?.paymentReference == "REF12345")
        #expect(intent?.references?.internalReference == "INT-001")
    }

    @Test("When Amount is missing, then result is nil")
    func testReturnsNilWhenAmountMissing() {
        let intent = PaymentIntent {
            Payer(reference: "john@example.com") {
                Payer.Person(firstName: "John", lastName: "Doe")
            }
            TransactionType.bill
        }

        #expect(intent == nil)
    }

    @Test("When Payer is missing, then result is nil")
    func testReturnsNilWhenPayerMissing() {
        let intent = PaymentIntent {
            Amount(currency: .GBP, minorUnits: 200)
            TransactionType.other
        }

        #expect(intent == nil)
    }

    @Test("When TransactionType is missing, then result is nil")
    func testReturnsNilWhenTransactionTypeMissing() {
        let intent = PaymentIntent {
            Amount(currency: .EUR, minorUnits: 100)
            Payer(reference: "john@example.com") {
                Payer.Person(firstName: "John", lastName: "Doe")
            }
        }

        #expect(intent == nil)
    }

    @Test("When Amount failable init returns nil, then result is nil")
    func testReturnsNilWhenAmountInvalid() {
        let intent = PaymentIntent {
            Amount(currency: .EUR, minorUnits: 0)  // 0 is invalid
            Payer(reference: "john@example.com") {
                Payer.Person(firstName: "John", lastName: "Doe")
            }
            TransactionType.goods
        }

        #expect(intent == nil)
    }

    @Test("When Payer failable init returns nil due to invalid reference, then result is nil")
    func testReturnsNilWhenPayerReferenceInvalid() {
        let intent = PaymentIntent {
            Amount(currency: .EUR, minorUnits: 100)
            Payer(reference: "") {  // empty string is invalid
                Payer.Person(firstName: "John", lastName: "Doe")
            }
            TransactionType.goods
        }

        #expect(intent == nil)
    }

    @Test("When PaymentReferences failable init returns nil, then result is nil")
    func testReturnsNilWhenReferencesInvalid() {
        let intent = PaymentIntent {
            Amount(currency: .EUR, minorUnits: 100)
            Payer(reference: "john@example.com") {
                Payer.Person(firstName: "John", lastName: "Doe")
            }
            TransactionType.goods
            PaymentReferences(paymentReference: "TOO-LONG-REF-1234567890")
        }

        #expect(intent == nil)
    }

    @Test("When components are declared in different order, then PaymentIntent is still created correctly")
    func testComponentOrderIndependence() {
        let intent = PaymentIntent {
            TransactionType.bill
            Payer(reference: "ref-123") {
                Payer.Organization(name: "Corp")
            }
            Amount(currency: .NOK, minorUnits: 999)
        }

        #expect(intent?.transactionType == .bill)
        #expect(intent?.amount.currency == .NOK)
        #expect(intent?.amount.minorUnits == 999)
    }

    @Test("When all transaction types are used, then each is preserved correctly")
    func testAllTransactionTypes() {
        let types: [TransactionType] = [.bill, .goods, .services, .other]

        for type in types {
            let intent = PaymentIntent {
                Amount(currency: .EUR, minorUnits: 1)
                Payer(reference: "ref") { Payer.Person(firstName: "A", lastName: "B") }
                type
            }
            #expect(intent?.transactionType == type)
        }
    }

    // MARK: - PayerEntityBuilder

    @Test("When only Person is provided, then entity is .person")
    func testPersonEntity() {
        let payer = Payer(reference: "john@example.com") {
            Payer.Person(firstName: "John", lastName: "Doe")
        }

        guard case .person(let person) = payer?.entity else {
            Issue.record("Expected .person entity")
            return
        }
        #expect(person.firstName == "John")
        #expect(person.lastName == "Doe")
    }

    @Test("When only Organization is provided, then entity is .organization")
    func testOrganizationEntity() {
        let payer = Payer(reference: "acme-corp") {
            Payer.Organization(name: "Acme Corp")
        }

        guard case .organization(let org) = payer?.entity else {
            Issue.record("Expected .organization entity")
            return
        }
        #expect(org.name == "Acme Corp")
    }

    @Test("When Person and Organization are provided, then entity is .both")
    func testBothEntity() {
        let payer = Payer(reference: "john@acme.com") {
            Payer.Person(firstName: "John", lastName: "Doe")
            Payer.Organization(name: "Acme Corp")
        }

        guard case .both(let person, let org) = payer?.entity else {
            Issue.record("Expected .both entity")
            return
        }
        #expect(person.firstName == "John")
        #expect(org.name == "Acme Corp")
    }

    @Test("When Organization and Person are provided in reverse order, then entity is .both")
    func testBothEntityReverseOrder() {
        let payer = Payer(reference: "john@acme.com") {
            Payer.Organization(name: "Acme Corp")
            Payer.Person(firstName: "John", lastName: "Doe")
        }

        if case .both = payer?.entity {
            #expect(payer?.entity != nil)
        } else {
            Issue.record("Expected .both entity regardless of declaration order")
        }
    }

    @Test("When reference string is invalid, then result is nil")
    func testReturnsNilForInvalidReference() {
        let payer = Payer(reference: "") {
            Payer.Person(firstName: "John", lastName: "Doe")
        }

        #expect(payer == nil)
    }

    @Test("When Person failable init returns nil, then result is nil")
    func testReturnsNilWhenPersonInvalid() {
        let longName = String(repeating: "x", count: 256)
        let payer = Payer(reference: "john@example.com") {
            Payer.Person(firstName: longName, lastName: "Doe")
        }

        #expect(payer == nil)
    }

    @Test("When Organization failable init returns nil, then result is nil")
    func testReturnsNilWhenOrganizationInvalid() {
        let longName = String(repeating: "x", count: 256)
        let payer = Payer(reference: "acme-corp") {
            Payer.Organization(name: longName)
        }

        #expect(payer == nil)
    }

    @Test("When email and phone are provided, then they are preserved on the payer")
    func testEmailAndPhoneArePreserved() {
        let payer = Payer(reference: "john@example.com", email: "john@example.com", phone: "+441234567890") {
            Payer.Person(firstName: "John", lastName: "Doe")
        }

        #expect(payer?.email == "john@example.com")
        #expect(payer?.phone == "+441234567890")
    }

    @Test("When no email or phone are provided, then they are nil on the payer")
    func testEmailAndPhoneDefaultToNil() {
        let payer = Payer(reference: "john@example.com") {
            Payer.Person(firstName: "John", lastName: "Doe")
        }

        #expect(payer?.email == nil)
        #expect(payer?.phone == nil)
    }

    @Test("When reference is valid, then reference value is preserved")
    func testReferenceValuePreserved() {
        let payer = Payer(reference: "customer-id-42") {
            Payer.Person(firstName: "Jane", lastName: "Smith")
        }

        #expect(payer?.reference.value == "customer-id-42")
    }
}
