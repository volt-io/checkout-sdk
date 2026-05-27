//
// PaymentFlowFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 05/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import Foundation
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Payment Flow Feature Tests")
@MainActor struct PaymentFlowFeatureTests {
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
    let inactiveItem = Institution.Item(
        id: "test-id-inactive",
        name: "Inactive Institution",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: nil,
        country: Country(.germany),
        isActive: false,
        accountIdentifiers: [],
    )
    let itemWithAccountIdentifiers = Institution.Item(
        id: "test-id-iban",
        name: "IBAN Institution",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: nil,
        country: Country(.germany),
        isActive: true,
        accountIdentifiers: [.IBAN],
    )
    let identifier = PaymentIdentifier(id: "test-payment", token: "test-token", status: .completed)

    @Test("When continue action comes with country hint, then institutions are appended to path with default country")
    func testContinueButtonActionWithHints() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .useDefaultCountry(country),
            path: .init([.educational(.init())])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].educational.onContinueButtonTapped) {
            $0.selectedCountry = country
            $0.path[id: 1] = .institutions(.init(currency: currency, defaultCountry: country))
        }
        await testStore.finish()
    }

    @Test("When continue action comes without hints, then institutions are appended to path without default country")
    func testContinueButtonActionWithoutHints() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.educational(.init())])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].educational.onContinueButtonTapped) {
            $0.path[id: 1] = .institutions(.init(currency: currency, defaultCountry: nil))
        }
        await testStore.finish()
    }

    @Test("When tap on group action comes, then branches feature is appended to path")
    func testOnTapGroupAction() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].institutions.onTappedGroup, group) {
            $0.path[id: 1] = .branches(.init(group: group))
        }
        await testStore.finish()
    }

    @Test("When tap on institution action comes, then selected institution is set and payment feature added to path")
    func testOnInstitutionAction() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].institutions.onTappedInstitution, item) {
            $0.selectedInstitution = item.asInstitution
            $0.path[id: 1] = .payment(.init(intent: intent, institution: item.asInstitution))
        }
        await testStore.finish()
    }

    @Test("When return to merchant action comes, then it yields nil result and dismiss action is received")
    func testReturnToMerchantAction() async throws {
        var isDismissed = false
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.payment(.init(intent: intent, institution: institution))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == nil)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].payment.delegate.onReturnToMerchant)

        #expect(isDismissed == true)
    }

    @Test("When flow completed action comes, then it yields non nil result and dismiss action is received")
    func testFlowCompletedAction() async throws {
        var isDismissed = false
        let expectedResult = CheckoutResult.paymentCreated(
            id: identifier.id,
            status: .init(identifier.status),
            institution: institution
        )
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.payment(.init(intent: intent, institution: institution))]),
            selectedInstitution: institution,
            paymentIdentifier:  identifier
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == expectedResult)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }

        await testStore.send(\.view.path[id: 0].payment.delegate.onReturnToMerchant)

        #expect(isDismissed == true)
    }

    @Test("When feedback sheet is submitted, then it yields nil result and and dismiss action is received")
    func testFeedbackSheetSubmit() async throws {
        var isDismissed = false
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.payment(.init(intent: intent, institution: institution))]),
            selectedInstitution: institution
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == nil)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].payment._internal.navBar.view.onCloseButtonTapped)
        await testStore.send(\.view.path[id: 0].payment._internal.navBar.delegate.onSubmitFeedback)

        #expect(isDismissed == true)
    }

    @Test("When inactive institution is tapped from institutions list, then no navigation occurs")
    func testInactiveInstitutionFromInstitutions() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].institutions.onTappedInstitution, inactiveItem)
        await testStore.receive(\.view.path[id: 0].institutions.onPopoverItemChanged, inactiveItem) {
            $0.path[id: 0, case: \.institutions]?.popoverItem = inactiveItem
        }
        await testStore.finish()
    }

    @Test("When inactive institution is tapped from branches list, then no navigation occurs")
    func testInactiveInstitutionFromBranches() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.branches(.init(group: group))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].branches.onTappedInstitution, inactiveItem)
        await testStore.receive(\.view.path[id: 0].branches.onPopoverItemChanged, inactiveItem) {
            $0.path[id: 0, case: \.branches]?.popoverItem = inactiveItem
        }
        await testStore.finish()
    }

    @Test("When active institution is tapped from branches list, then payment feature is appended to path")
    func testOnBranchInstitutionAction() async throws {
        let branchItem = group.branches.first(where: { $0.isActive })!
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.branches(.init(group: group))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].branches.onTappedInstitution, branchItem) {
            $0.selectedInstitution = branchItem.asInstitution
            $0.path[id: 1] = .payment(.init(intent: intent, institution: branchItem.asInstitution))
        }
        await testStore.finish()
    }

    @Test("When payment begins with useInstitution hint, then selected institution is set from hint")
    func testOnBeginPaymentWithUseInstitutionHint() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .useInstitution(institution),
            path: .init([.payment(.init(intent: intent, institution: institution))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].payment.delegate.onBeginPayment) {
            $0.selectedInstitution = institution
            $0.selectedCountry = institution.country
        }
        await testStore.finish()
    }

    @Test("When payment requires account identifiers, then account identifiers feature is appended to path")
    func testOnAccountIdentifiersRequired() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.payment(.init(intent: intent, institution: institution))]),
            selectedCountry: country
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].payment.delegate.onAccountIdentifiersRequired, itemWithAccountIdentifiers) {
            $0.path[id: 0, case: \.payment]?.progressState = .collectingAccountIdentifiers
            $0.path[id: 1] = .accountIdentifiers(.init(institution: itemWithAccountIdentifiers, country: country))
        }
        await testStore.finish()
    }

    @Test("When payment updated action comes, then payment identifier is stored")
    func testOnUpdatedPayment() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.payment(.init(intent: intent, institution: institution))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].payment.delegate.onUpdatedPayment, identifier) {
            $0.paymentIdentifier = identifier
        }
        await testStore.finish()
    }

    @Test("When select another bank action comes, then payment screen is popped from path")
    func testOnSelectAnotherBank() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([
                .institutions(.init(currency: currency, defaultCountry: nil)),
                .payment(.init(intent: intent, institution: institution)),
            ])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 1].payment.delegate.onSelectAnotherBank) {
            $0.path.removeLast()
        }
        await testStore.finish()

        #expect(testStore.state.path.count == 1)
    }

    @Test("When account identifiers are submitted, then screen is popped and data is forwarded to payment")
    func testOnAccountIdentifiersSubmitted() async throws {
        let accountIdentifiersData = AccountIdentifiersData(IBAN: "DE89370400440532013000")
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([
                .payment(.init(intent: intent, institution: institution)),
                .accountIdentifiers(.init(institution: itemWithAccountIdentifiers, country: country)),
            ])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.openURL = OpenURLEffect(handler: { _ in true })
        }

        await testStore.send(\.view.path[id: 1].accountIdentifiers.delegate.onSubmitted, accountIdentifiersData) {
            $0.path.removeLast()
        }
        await testStore.receive(\.view.path[id: 0].payment.delegate.onReceivedAccountIdentifiersData, accountIdentifiersData)
        testStore.exhaustivity = .off
        await testStore.finish()

        #expect(testStore.state.path.count == 1)
    }

    @Test("When return to merchant comes from account identifiers screen, then it yields nil result and dismisses")
    func testAccountIdentifiersReturnToMerchant() async throws {
        var isDismissed = false
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([
                .payment(.init(intent: intent, institution: institution)),
                .accountIdentifiers(.init(institution: itemWithAccountIdentifiers, country: country)),
            ])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == nil)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 1].accountIdentifiers.delegate.onReturnToMerchant)

        #expect(isDismissed == true)
    }

    @Test("When feedback is submitted from educational screen, then it yields nil result and dismisses")
    func testEducationalFeedbackSubmit() async throws {
        var isDismissed = false
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.educational(.init())])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == nil)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].educational.navBar.view.onCloseButtonTapped)
        await testStore.send(\.view.path[id: 0].educational.navBar.delegate.onSubmitFeedback)

        #expect(isDismissed == true)
    }

    @Test("When feedback is submitted from institutions screen, then it yields nil result and dismisses")
    func testInstitutionsFeedbackSubmit() async throws {
        var isDismissed = false
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
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

    @Test("When feedback is submitted from branches screen, then it yields nil result and dismisses")
    func testBranchesFeedbackSubmit() async throws {
        var isDismissed = false
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.branches(.init(group: group))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.checkoutResult.yieldResult = { result in
                #expect(result == nil)
            }
            $0.dismiss = DismissEffect {
                isDismissed = true
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].branches.navBar.view.onCloseButtonTapped)
        await testStore.send(\.view.path[id: 0].branches.navBar.delegate.onSubmitFeedback)

        #expect(isDismissed == true)
    }

    @Test("When selected country changes in institutions, then selected country is updated")
    func testOnSelectedCountryChanged() async throws {
        let newCountry = Country(.poland)
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.institutions(.init(currency: currency, defaultCountry: nil))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        } withDependencies: {
            $0.voltAPI.getInstitutions = { _, _ in [] }
            $0.groupInstitutions.group = { _ in [] }
        }
        testStore.exhaustivity = .off

        await testStore.send(\.view.path[id: 0].institutions.onSelectedCountryChanged, newCountry) {
            $0.selectedCountry = newCountry
        }
        await testStore.finish()
    }

    @Test("When account identifiers are required but selected country is nil, then no navigation occurs")
    func testOnAccountIdentifiersRequiredWithoutCountry() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.payment(.init(intent: intent, institution: institution))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].payment.delegate.onAccountIdentifiersRequired, itemWithAccountIdentifiers) {
            $0.path[id: 0, case: \.payment]?.progressState = .collectingAccountIdentifiers
        }
        await testStore.finish()
    }

    @Test("When payment begins without useInstitution hint, then no state change occurs")
    func testOnBeginPaymentWithoutUseInstitutionHint() async throws {
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([.payment(.init(intent: intent, institution: institution))])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].payment.delegate.onBeginPayment)
        await testStore.finish()
    }

    @Test("When account identifiers are submitted but no payment screen remains in path, then no forwarding occurs")
    func testOnAccountIdentifiersSubmittedWithNoPaymentInPath() async throws {
        let accountIdentifiersData = AccountIdentifiersData(IBAN: "DE89370400440532013000")
        let testState = PaymentFlowFeature.State(
            intent: intent,
            hints: .none,
            path: .init([
                .accountIdentifiers(.init(institution: itemWithAccountIdentifiers, country: country)),
            ])
        )
        let testStore = TestStore(initialState: testState) {
            PaymentFlowFeature()
        }

        await testStore.send(\.view.path[id: 0].accountIdentifiers.delegate.onSubmitted, accountIdentifiersData) {
            $0.path.removeAll()
        }
        await testStore.finish()

        #expect(testStore.state.path.count == 0)
    }
}
