//
// PaymentUseCasesTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 28/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
import AsyncAlgorithms
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Payment Use Cases Tests")
struct PaymentUseCasesTests {
    static let redirectURL = URL(string: "https://redirect-url.com")!
    let currency = Currency.EUR
    let country = Country(.germany)
    let institution = Institution(
        id: "643df330-d162-4202-a732-784f64ee85c1",
        name: "Berliner Sparkasse",
        logo: URL(string: "https://cdn.volt.io/chk3_banks/logos/xx_sparkasse.svg"),
        country: Country(.germany)
    )
    let institutionItem = Institution.Item(
        id: "643df330-d162-4202-a732-784f64ee85c1",
        name: "Berliner Sparkasse",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: URL(string: "https://cdn.volt.io/chk3_banks/logos/xx_sparkasse.svg"),
        country: .init(.germany),
        isActive: true,
        accountIdentifiers: [],
    )
    let inactiveInstitutionItem = Institution.Item(
        id: "643df330-d162-4202-a732-784f64ee85c1",
        name: "Berliner Sparkasse",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: URL(string: "https://cdn.volt.io/chk3_banks/logos/xx_sparkasse.svg"),
        country: .init(.germany),
        isActive: false,
        accountIdentifiers: [],
    )
    let accountIdentifiersInstitutionItem = Institution.Item(
        id: "643df330-d162-4202-a732-784f64ee85c1",
        name: "Berliner Sparkasse",
        alternativeName: nil,
        groupName: nil,
        branchName: nil,
        logo: URL(string: "https://cdn.volt.io/chk3_banks/logos/xx_sparkasse.svg"),
        country: .init(.germany),
        isActive: true,
        accountIdentifiers: [.IBAN, .PSUId],
    )
    let EURIntent = PaymentIntent(
        amount: Amount(currency: .EUR, minorUnits: 100)!,
        payer: Payer(
            reference: Payer.Reference("johneur@example.com")!,
            entity: .person(Payer.Person(firstName: "John", lastName: "Eur")!)
        ),
        transactionType: .goods
    )
    let GBPIntent = PaymentIntent(
        amount: Amount(currency: .GBP, minorUnits: 100)!,
        payer: Payer(
            reference: Payer.Reference("johngbp@example.com")!,
            entity: .person(Payer.Person(firstName: "John", lastName: "Gbp")!)
        ),
        transactionType: .goods
    )
    let EURAccountIdentifiers = AccountIdentifiersData(IBAN: "DE12345", branchCode: nil, accountNumber: nil, PSUId: "john@psuid")
    let GBPAccountIdentifiers = AccountIdentifiersData(accountNumber: .init(countryCode: .unitedKingdom, number: "12345678"))
    let paymentIdentifier = PaymentIdentifier(id: "test-payment", token: "test-token", status: .newPayment)
    var response1: PaymentResponse {
        try! ResourceReader.readJSON("PaymentResponse-1", to: PaymentResponse.self)
    }
    var response2: PaymentResponse {
        try! ResourceReader.readJSON("PaymentResponse-2", to: PaymentResponse.self)
    }
    var response3: PaymentResponse {
        try! ResourceReader.readJSON("PaymentResponse-3", to: PaymentResponse.self)
    }
    var response4: PaymentResponse {
        try! ResourceReader.readJSON("PaymentResponse-4", to: PaymentResponse.self)
    }

    @Test("When mapping between transaction type and payment type, then mapping is correct")
    func testPaymentTransactionTypeMapping() async throws {
        #expect(TransactionType.bill.paymentType == .bill)
        #expect(TransactionType.goods.paymentType == .goods)
        #expect(TransactionType.services.paymentType == .services)
        #expect(TransactionType.other.paymentType == .other)
    }

    @Test("When creating payment with EUR currency, then request uses openBankingEU payment system")
    func testBuildingPaymentRequestEU() async throws {
        let testUseCase = CreatePaymentUseCase.testValue
        nonisolated(unsafe) var capturedRequest: PaymentRequest?

        try await withDependencies {
            $0.voltAPI.createPayment = { request in
                capturedRequest = request
                return response1
            }
        } operation: {
            _ = try await testUseCase.create(EURIntent, institution, EURAccountIdentifiers)
        }

        #expect(capturedRequest?.currency == EURIntent.amount.currency.rawValue)
        #expect(capturedRequest?.amount == EURIntent.amount.minorUnits)
        #expect(capturedRequest?.paymentReference == EURIntent.references?.paymentReference)
        #expect(capturedRequest?.internalReference == EURIntent.references?.internalReference)
        #expect(capturedRequest?.payer.reference == EURIntent.payer.reference.value)
        #expect(capturedRequest?.device.ip == "1.1.1.1")
        #expect(capturedRequest?.paymentSystem == .openBankingEU)
        #expect(capturedRequest?.openBankingEU?.institutionId == institution.id)
        #expect(capturedRequest?.openBankingEU?.type == EURIntent.transactionType.paymentType)
        #expect(capturedRequest?.openBankingEU?.accountIdentifiers.iban == EURAccountIdentifiers.IBAN?.rawValue)
        #expect(capturedRequest?.openBankingEU?.accountIdentifiers.psuId == EURAccountIdentifiers.PSUId?.rawValue)
        #expect(capturedRequest?.openBankingEU?.accountIdentifiers.branchCode == nil)
        #expect(capturedRequest?.openBankingEU?.accountIdentifiers.accountNumber == nil)
        #expect(capturedRequest?.openBankingUK == nil)
    }

    @Test("When creating payment with GBP currency, then request uses openBankingUK payment system")
    func testBuildingPaymentRequestUK() async throws {
        let testUseCase = CreatePaymentUseCase.testValue
        nonisolated(unsafe) var capturedRequest: PaymentRequest?

        try await withDependencies {
            $0.voltAPI.createPayment = { request in
                capturedRequest = request
                return response4
            }
        } operation: {
            _ = try await testUseCase.create(GBPIntent, institution, GBPAccountIdentifiers)
        }

        #expect(capturedRequest?.currency == GBPIntent.amount.currency.rawValue)
        #expect(capturedRequest?.amount == GBPIntent.amount.minorUnits)
        #expect(capturedRequest?.paymentReference == GBPIntent.references?.paymentReference)
        #expect(capturedRequest?.internalReference == GBPIntent.references?.internalReference)
        #expect(capturedRequest?.payer.reference == GBPIntent.payer.reference.value)
        #expect(capturedRequest?.device.ip == "1.1.1.1")
        #expect(capturedRequest?.paymentSystem == .openBankingUK)
        #expect(capturedRequest?.openBankingUK?.institutionId == institution.id)
        #expect(capturedRequest?.openBankingUK?.type == GBPIntent.transactionType.paymentType)
        #expect(capturedRequest?.openBankingUK?.accountIdentifiers.iban == nil)
        #expect(capturedRequest?.openBankingUK?.accountIdentifiers.psuId == nil)
        #expect(capturedRequest?.openBankingUK?.accountIdentifiers.branchCode == nil)
        #expect(capturedRequest?.openBankingUK?.accountIdentifiers.accountNumber == GBPAccountIdentifiers.accountNumber?.number)
        #expect(capturedRequest?.openBankingEU == nil)
    }

    @Test("When resolving progress for EUR payment, then provider is sourced from openBankingEU")
    func testResolveProgressEUProviderUsed() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let state = useCase.resolve(response1)
        #expect(state == .processing(provider: "Volt"))
    }

    @Test("When resolving progress for GBP payment, then provider is sourced from openBankingUK")
    func testResolveProgressUKProviderUsed() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let state = useCase.resolve(response4)
        #expect(state == .processing(provider: "Volt"))
    }

    @Test("When resolving progress for EUR payment awaiting redirect URL, then processing state is returned with provider")
    func testResolveProgressAwaitingRedirectURL() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let state = useCase.resolve(response2)
        #expect(state == .processing(provider: "Volt"))
    }

    @Test("When resolving progress and redirect is available, then awaitingRedirect state is returned")
    func testResolveProgressAwaitingRedirect() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let state = useCase.resolve(response3)
        #expect(state == .awaitingRedirect(url: Self.redirectURL))
    }

    @Test("When verifying institution, then institution details are requested")
    func testVerifyInstitutionCallsGetInstitution() async throws {
        let testUseCase = VerifyInstitutionUseCase.testValue
        nonisolated(unsafe) var capturedId: String?

        try await withDependencies {
            $0.voltAPI.getInstitution = { id in
                capturedId = id
                return institutionItem
            }
        } operation: {
            _ = try await testUseCase.verify(institution: institution)
        }

        #expect(capturedId == institution.id)
    }

    @Test("When verifying institution with inactive institution, then payment error is thrown")
    func testVerifyInstitutionFailsWithInactiveInstitution() async throws {
        let testUseCase = VerifyInstitutionUseCase.testValue

        await withDependencies {
            $0.voltAPI.getInstitution = { _ in inactiveInstitutionItem }
        } operation: {
            await #expect(throws: PaymentError.institutionNotActive, performing: {
                _ = try await testUseCase.verify(institution: institution)
            })
        }
    }

    @Test("When verifying institution with required account identifiers, then institution item is returned")
    func testVerifyInstitutionReturnsAccountIdentifiers() async throws {
        let testUseCase = VerifyInstitutionUseCase.testValue
        nonisolated(unsafe) var result: Institution.Item?

        try await withDependencies {
            $0.voltAPI.getInstitution = { _ in accountIdentifiersInstitutionItem }
        } operation: {
            result = try await testUseCase.verify(institution: institution)
        }

        #expect(result?.accountIdentifiers == [.IBAN, .PSUId])
    }

    @Test("When polling for payment status, then it yields updates until redirect url comes")
    func testPollingUpdates() async throws {
        let testUseCase = GetPaymentStatusUseCase.testValue

        let expectedResponses = [response2, response2, response2, response3]
        var capturedUpdate: [GetPaymentStatusUseCase.Update] = []
        nonisolated(unsafe) var retryCount = 0

        try await withDependencies {
            $0.voltAPI.getPayment = { _, _ in
                retryCount += 1
                return expectedResponses[retryCount - 1]
            }
            $0.suspendingClock = ImmediateClock()
        } operation: {
            for try await update in testUseCase.status(paymentIdentifier: paymentIdentifier) {
                capturedUpdate.append(update)
            }

            #expect(retryCount == expectedResponses.count)
            #expect(capturedUpdate.count == expectedResponses.count)
            #expect(capturedUpdate.last?.progressState == .some(.awaitingRedirect(url: Self.redirectURL)))
        }
    }

    @Test("When polling for payment status, then it fails when max retries are reached")
    func testPollingMaxRetriesReached() async throws {
        let testUseCase = GetPaymentStatusUseCase.testValue

        await withDependencies {
            $0.voltAPI.getPayment = { _, _ in response2 }
            $0.suspendingClock = ImmediateClock()
        } operation: {
            await #expect(throws: PaymentError.maxRetriesReached, performing: {
                for try await _ in testUseCase.status(paymentIdentifier: paymentIdentifier) { /* drain */ }
            })
        }
    }

    @Test("When polling for payment status, then it propagates underlying error when thrown")
    func testPollingAPIErrorPropagation() async throws {
        let testUseCase = GetPaymentStatusUseCase.testValue
        struct TestError: Error {}

        await withDependencies {
            $0.voltAPI.getPayment = { _, _ in throw TestError() }
        } operation: {
            await #expect(throws: TestError.self, performing: {
                for try await _ in testUseCase.status(paymentIdentifier: paymentIdentifier) { /* drain */ }
            })
        }
    }

    @Test("When status is success and redirect is available, then success takes priority over redirect")
    func testResolvePrioritySuccessOverRedirect() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let response = makeResponse(status: .completed, reason: .awaitingUserRedirect, redirectURL: "https://example.com")
        #expect(useCase.resolve(response) == .succeeded)
    }

    @Test("When status is error and redirect is available, then error takes priority over redirect")
    func testResolvePriorityErrorOverRedirect() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let response = makeResponse(status: .failed, reason: .awaitingUserRedirect, redirectURL: "https://example.com")
        #expect(useCase.resolve(response) == .failed(error: .failed(.failed)))
    }

    @Test("When status is error and input is required, then error takes priority over input required")
    func testResolvePriorityErrorOverInputRequired() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let response = makeResponse(
            status: .failed,
            flowStatus: .waitingForInput,
            requiredInput: [.init(name: .IBAN, propertyPath: "payer.accountIdentifiers.iban")]
        )
        #expect(useCase.resolve(response) == .failed(error: .failed(.failed)))
    }

    @Test("When status is delayed and input is required, then delayed takes priority over required input")
    func testResolvePriorityDelayedOverInputRequired() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let response = makeResponse(
            status: .delayedAtBank,
            flowStatus: .waitingForInput,
            requiredInput: [.init(name: .IBAN, propertyPath: "payer.accountIdentifiers.iban")]
        )
        #expect(useCase.resolve(response) == .delayed)
    }

    @Test("When status is delayed and redirect is available, then delayed takes priority over redirect")
    func testResolvePriority_delayedOverRedirect() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let response = makeResponse(status: .delayedAtBank, reason: .awaitingUserRedirect, redirectURL: "https://example.com")
        #expect(useCase.resolve(response) == .delayed)
    }

    @Test("When input is required and redirect is available, then input required takes priority over redirect")
    func testResolvePriority_inputRequiredOverRedirect() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let response = makeResponse(
            status: .newPayment,
            flowStatus: .waitingForInput,
            reason: .awaitingUserRedirect,
            redirectURL: "https://example.com",
            requiredInput: [.init(name: .IBAN, propertyPath: "payer.accountIdentifiers.iban")]
        )
        #expect(useCase.resolve(response) == .processing(provider: nil))
    }

    @Test("When status is success and input is required, then success takes priority over input required")
    func testResolvePriority_successOverInputRequired() {
        let useCase = ResolvePaymentProgressUseCase.testValue
        let response = makeResponse(
            status: .completed,
            flowStatus: .waitingForInput,
            requiredInput: [.init(name: .IBAN, propertyPath: "payer.accountIdentifiers.iban")]
        )
        #expect(useCase.resolve(response) == .succeeded)
    }

    private func makeResponse(
        status: PaymentStatus,
        flowStatus: PaymentResponse.PaymentInitiationStatus = .processing,
        reason: PaymentResponse.PaymentInitiationReason = .awaitingSDKHandoff,
        redirectURL: String? = nil,
        requiredInput: [PaymentResponse.RequiredInput]? = nil
    ) -> PaymentResponse {
        PaymentResponse(
            id: "test-id",
            currency: "EUR",
            amount: 100,
            paymentReference: "test-ref",
            internalReference: nil,
            paymentSystem: .openBankingEU,
            openBankingEU: nil,
            openBankingUK: nil,
            status: status,
            paymentInitiationFlow: .init(
                status: flowStatus,
                details: .init(
                    reason: reason,
                    redirect: redirectURL.map { .init(url: $0, directUrl: $0) },
                    token: nil
                ),
                requiredInput: requiredInput
            )
        )
    }
}
