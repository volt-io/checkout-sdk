//
// PaymentFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
import AsyncAlgorithms
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Payment Feature Tests")
@MainActor struct PaymentFeatureTests {
    static let redirectURL = URL(string: "https://redirect-url.com")!

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
    let identifier1 = PaymentIdentifier(id: "test-payment", token: "test-token", status: .newPayment)
    let identifier2 = PaymentIdentifier(id: "test-payment", token: "test-token", status: .approvedByRisk)
    let identifier3 = PaymentIdentifier(id: "test-payment", token: "test-token", status: .bankRedirect)
    let update1: GetPaymentStatusUseCase.Update = (
        PaymentIdentifier(id: "test-payment", token: "test-token", status: .newPayment),
        .processing(provider: nil)
    )
    let update2: GetPaymentStatusUseCase.Update = (
        PaymentIdentifier(id: "test-payment", token: "test-token", status: .approvedByRisk),
        .processing(provider: "Provider Name")
    )
    let update3: GetPaymentStatusUseCase.Update = (
        PaymentIdentifier(id: "test-payment", token: "test-token", status: .bankRedirect),
        .awaitingRedirect(url: Self.redirectURL)
    )
    let feedbackState = FeedbackFeature.State(
        context: PaymentFeedback().context,
        options: PaymentFeedback().options
    )

    @Test("When creating payment with no account identifiers required, then it completes the flow successfully")
    func testCreatePaymentAndComplete() async throws {
        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.createPayment.create = { _, _, _ in identifier1 }
            $0.paymentStatus.status = { _ in
                let channel = AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>()
                Task {
                    await channel.send(update2)
                    await channel.send(update3)
                    channel.finish()
                }
                return channel
            }
            $0.openURL = OpenURLEffect { _ in true }
            $0.analytics.track = { _, _ in }
            $0.dismiss = DismissEffect { }
        }

        await testStore.send(._internal(.createPayment(AccountIdentifiersData())))

        await testStore.receive(\._internal.createdPayment) {
            $0.identifier = update1.paymentIdentifier
            $0.progressState = update1.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)
        await testStore.receive(\._internal.startStatusPolling)
        await testStore.receive(\._internal.updatedPayment) {
            $0.identifier = update2.paymentIdentifier
            $0.progressState = update2.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)
        await testStore.receive(\._internal.updatedPayment) {
            $0.identifier = update3.paymentIdentifier
            $0.progressState = update3.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)
        await testStore.receive(\._internal.openRedirect)
    }

    @Test("When creating payment fails, then finished with failure state is set")
    func testPaymentFailure() async throws {
        struct TestError: Error {}
        let expectedError = TestError()

        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.createPayment.create = { _, _, _ in
                throw expectedError
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(.view(.onAppear))
        await testStore.receive(\._internal.paymentFailed) {
            $0.progressState = .failed(error: .unknown(expectedError))
        }
    }

    @Test("When polling for payment status fails, then finished with failure state is set")
    func testPaymentStatusPollingFailure() async throws {
        struct TestError: Error {}
        let expectedError = TestError()

        var testState = PaymentFeature.State(intent: intent, institution: institution, identifier: identifier1)
        testState.progressState = .processing(provider: "Provider name")
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.paymentStatus.status = { _ in
                let channel = AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>()
                Task {
                    await channel.send(update2)
                    channel.fail(expectedError)
                }
                return channel
            }
        }

        await testStore.send(._internal(.startStatusPolling(identifier1)))
        await testStore.receive(\._internal.updatedPayment) {
            $0.identifier = update2.paymentIdentifier
            $0.progressState = update2.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)
        await testStore.receive(\._internal.paymentFailed) {
            $0.progressState = .failed(error: .unknown(expectedError))
        }
    }

    @Test("When redirect url is received and feedback sheet is hidden, then redirect url is opened")
    func testOnReceivedTriggersRedirect() async throws {
        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.openURL = OpenURLEffect { _ in true }
            $0.analytics.track = { _, _ in }
            $0.dismiss = DismissEffect { }
        }

        await testStore.send(._internal(.updatedPayment(update3))) {
            $0.identifier = update3.paymentIdentifier
            $0.progressState = update3.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)
        await testStore.receive(\._internal.openRedirect)
    }

    @Test("When feedback sheet is visible and redirect url comes, then redirect waits")
    func testOnReceivedWaitsWithRedirect() async throws {
        var testState = PaymentFeature.State(intent: intent, institution: institution, identifier: identifier1)
        testState.progressState = .processing(provider: "Provider name")
        testState.navBar.feedback = feedbackState

        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.paymentStatus.status = { _ in
                let channel = AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>()
                Task {
                    await channel.send(update2)
                    await channel.send(update3)
                    channel.finish()
                }
                return channel
            }
            $0.openURL = OpenURLEffect { _ in true }
            $0.analytics.track = { _, _ in }
            $0.dismiss = DismissEffect { }
        }

        await testStore.send(._internal(.startStatusPolling(identifier1)))
        await testStore.receive(\._internal.updatedPayment) {
            $0.identifier = update2.paymentIdentifier
            $0.progressState = update2.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)
        await testStore.receive(\._internal.updatedPayment) {
            $0.identifier = update3.paymentIdentifier
            $0.progressState = update3.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)

        #expect(testStore.state.isFeedbackSheetPresented == true)
        #expect(testStore.state.progressState == .awaitingRedirect(url: Self.redirectURL))
    }

    @Test("When feedback sheet is dismissed, then pending redirect is resumed after defined delay")
    func testResumeRedirect() async throws {
        let testQueue = DispatchQueue.test
        var testState = PaymentFeature.State(intent: intent, institution: institution)
        testState.progressState = .awaitingRedirect(url: Self.redirectURL)
        testState.navBar.feedback = feedbackState

        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.mainQueue = testQueue.eraseToAnyScheduler()
            $0.openURL = OpenURLEffect { url in await url == Self.redirectURL }
        }

        await testStore.send(._internal(.navBar(._internal(.feedback(.dismiss))))) {
            $0.navBar.feedback = nil
        }
        await testStore.receive(\._internal.navBar.delegate.onDismissFeedback)
        await testQueue.advance(by: .seconds(0.5))

        await testStore.receive(\._internal.openRedirect)
    }

    @Test("When feedback sheet is submitted, then payment cancellation is requested when possible")
    func testFeedbackSheetSubmit() async throws {
        nonisolated(unsafe) var cancelPaymentCalled = false

        let testState = PaymentFeature.State(intent: intent, institution: institution)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.voltAPI.cancelPayment = { _, _ in cancelPaymentCalled = true }
        }
        testStore.exhaustivity = .off

        await testStore.send(._internal(.createdPayment(identifier1))) {
            $0.identifier = identifier1
        }
        await testStore.send(._internal(.navBar(.view(.onCloseButtonTapped)))) {
            $0.navBar.feedback = feedbackState
        }
        await testStore.send(._internal(.navBar(.delegate(.onSubmitFeedback))))

        #expect(cancelPaymentCalled == true)
    }

    @Test("When return to merchant action is sent, then event is tracked and cancellation requested when possible")
    func testReturnToMerchant() async throws {
        let expectedEventName = Event.Name.placeholderEvent
        nonisolated(unsafe) var recordedEvents: [Event] = []
        nonisolated(unsafe) var cancelPaymentCalled = false

        let testState = PaymentFeature.State(intent: intent, institution: institution)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.analytics.track = { _, _ in recordedEvents.append(Event(name: expectedEventName, properties: [:])) }
            $0.voltAPI.cancelPayment = { _, _ in cancelPaymentCalled = true }
            $0.openURL = OpenURLEffect { _ in true }
        }
        testStore.exhaustivity = .off

        await testStore.send(._internal(.createdPayment(identifier1))) {
            $0.identifier = identifier1
        }
        await testStore.send(.view(.onReturnToMerchantTapped))

        #expect(recordedEvents[0].name == expectedEventName)
        #expect(recordedEvents.count == 1)
        #expect(cancelPaymentCalled == true)
    }

    @Test("When select another bank action is sent, then event is tracked and cancellation requested when possible")
    func testSelectAnotherBank() async throws {
        let expectedEventName = Event.Name.placeholderEvent
        nonisolated(unsafe) var recordedEvents: [Event] = []
        nonisolated(unsafe) var cancelPaymentCalled = false

        let testState = PaymentFeature.State(intent: intent, institution: institution)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.analytics.track = { _, _ in recordedEvents.append(Event(name: expectedEventName, properties: [:])) }
            $0.voltAPI.cancelPayment = { _, _ in cancelPaymentCalled = true }
            $0.openURL = OpenURLEffect { _ in true }
        }
        testStore.exhaustivity = .off

        await testStore.send(._internal(.createdPayment(identifier1))) {
            $0.identifier = identifier1
        }
        await testStore.send(.view(.onSelectAnotherBankTapped))

        #expect(recordedEvents[0].name == expectedEventName)
        #expect(recordedEvents.count == 1)
        #expect(cancelPaymentCalled == true)
    }

    @Test("When onAppear is sent and identifier already exists, then nothing happens")
    func testOnAppearWithExistingIdentifier() async throws {
        let testState = PaymentFeature.State(intent: intent, institution: institution, identifier: identifier1)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.paymentStatus.status = { _ in AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>() }
            $0.analytics.track = { _, _ in }
        }

        await testStore.send(.view(.onAppear))
        await testStore.finish()
    }

    @Test("When identifier already exists and scene phase changes to .active, then status polling starts")
    func testOnScenePhaseChangeActiveExistingIdentifier() async throws {
        let testState = PaymentFeature.State(intent: intent, institution: institution, identifier: identifier1)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.paymentStatus.status = { _ in AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>() }
            $0.analytics.track = { _, _ in }
        }
        testStore.exhaustivity = .off

        await testStore.send(.view(.onScenePhaseChange(.active)))
        await testStore.receive(\._internal.startStatusPolling)
    }

    @Test("When identifier already exists and scene phase changes to other than .active, then nothing happens")
    func testOnScenePhaseChangeNotActiveExistingIdentifier() async throws {
        let testState = PaymentFeature.State(intent: intent, institution: institution, identifier: identifier1)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.paymentStatus.status = { _ in AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>() }
            $0.analytics.track = { _, _ in }
        }
        testStore.exhaustivity = .off

        await testStore.send(.view(.onScenePhaseChange(.background)))
        await testStore.finish()
    }

    @Test("When flow is abandoned before payment was created, then cancel request is not called")
    func testCancellationBeforePaymentCreated() async throws {
        nonisolated(unsafe) var cancelPaymentCalled = false

        var testState = PaymentFeature.State(intent: intent, institution: institution)
        testState.navBar.feedback = feedbackState
        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.voltAPI.cancelPayment = { _, _ in cancelPaymentCalled = true }
        }
        testStore.exhaustivity = .off

        await testStore.send(._internal(.navBar(.delegate(.onSubmitFeedback))))
        await testStore.finish()
        #expect(cancelPaymentCalled == false)

        await testStore.send(.view(.onReturnToMerchantTapped))
        await testStore.finish()
        #expect(cancelPaymentCalled == false)

        await testStore.send(.view(.onSelectAnotherBankTapped))
        await testStore.finish()
        #expect(cancelPaymentCalled == false)
    }

    @Test("When flow is abandoned while polling for status, then polling is cancelled")
    func testCancellationCancelsStatusPolling() async throws {
        let testState = PaymentFeature.State(intent: intent, institution: institution, identifier: identifier1)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.paymentStatus.status = { _ in AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>() }
        }

        await testStore.send(._internal(.startStatusPolling(identifier1)))
        await testStore.send(.view(.onReturnToMerchantTapped))
        await testStore.receive(\._internal.cancelPaymentIfPossible)
        await testStore.receive(\.delegate.onReturnToMerchant)
        await testStore.finish()
    }

    @Test("When onAppear is sent but state is not verifying, then nothing happens")
    func testOnAppearGuardSkipsWhenNotVerifying() async throws {
        var testState = PaymentFeature.State(intent: intent, institution: institution)
        testState.progressState = .processing(provider: nil)

        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        }

        await testStore.send(.view(.onAppear))
        await testStore.finish()
    }

    @Test("When institution has no account identifiers, then payment is created directly after verification")
    func testVerifyInstitutionNoAccountIdentifiers() async throws {
        let institutionItem = Institution.Item(
            id: institution.id,
            name: institution.name,
            alternativeName: nil,
            groupName: nil,
            branchName: nil,
            logo: nil,
            country: institution.country,
            isActive: true,
            accountIdentifiers: [],
        )

        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.verifyInstitution.verify = { _ in institutionItem }
            $0.createPayment.create = { _, _, _ in identifier1 }
            $0.paymentStatus.status = { _ in
                let channel = AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>()
                channel.finish()
                return channel
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(.view(.onAppear))
        await testStore.receive(\.delegate.onBeginPayment)
        await testStore.receive(\._internal.createPayment)
        await testStore.finish()
    }

    @Test("When institution requires account identifiers, then delegate action is sent after verification")
    func testVerifyInstitutionAccountIdentifiersRequired() async throws {
        let institutionItem = Institution.Item(
            id: institution.id,
            name: institution.name,
            alternativeName: nil,
            groupName: nil,
            branchName: nil,
            logo: nil,
            country: institution.country,
            isActive: true,
            accountIdentifiers: [.IBAN],
        )

        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.verifyInstitution.verify = { _ in institutionItem }
        }

        await testStore.send(.view(.onAppear))
        await testStore.receive(\.delegate.onBeginPayment)
        await testStore.receive(\._internal.verifyInstitution)
        await testStore.receive(\.delegate.onAccountIdentifiersRequired) {
            $0.progressState = .collectingAccountIdentifiers
        }
        await testStore.finish()
    }

    @Test("When institution verification fails, then payment failed state is set")
    func testVerifyInstitutionFailure() async throws {
        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.verifyInstitution.verify = { _ in throw PaymentError.institutionNotActive }
        }
        testStore.exhaustivity = .off

        await testStore.send(.view(.onAppear))
        await testStore.receive(\._internal.paymentFailed) {
            $0.progressState = .failed(error: .institutionNotActive)
        }
        await testStore.finish()
    }

    @Test("When account identifiers required delegate action is sent, then progress state is set to collecting")
    func testOnAccountIdentifiersRequired() async throws {
        let institutionItem = Institution.Item(
            id: institution.id,
            name: institution.name,
            alternativeName: nil,
            groupName: nil,
            branchName: nil,
            logo: nil,
            country: institution.country,
            isActive: true,
            accountIdentifiers: [.IBAN],
        )

        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        }

        await testStore.send(.delegate(.onAccountIdentifiersRequired(institutionItem))) {
            $0.progressState = .collectingAccountIdentifiers
        }
        await testStore.finish()
    }

    @Test("When received account identifiers data delegate action is sent, then create payment is triggered")
    func testOnReceivedAccountIdentifiersData() async throws {
        let accountIdentifiersData = AccountIdentifiersData(IBAN: "DE89370400440532013000")

        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        } withDependencies: {
            $0.createPayment.create = { _, _, _ in identifier1 }
            $0.paymentStatus.status = { _ in
                let channel = AsyncThrowingChannel<GetPaymentStatusUseCase.Update, Error>()
                channel.finish()
                return channel
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(.delegate(.onReceivedAccountIdentifiersData(accountIdentifiersData)))
        await testStore.receive(\._internal.createPayment, accountIdentifiersData)
        await testStore.finish()
    }

    @Test("When payment update contains a failed progress state, then payment failed action is triggered")
    func testUpdatedPaymentWithFailedState() async throws {
        let failedUpdate: GetPaymentStatusUseCase.Update = (
            PaymentIdentifier(id: "test-payment", token: "test-token", status: .failed),
            .failed(error: .failed(.failed))
        )

        let testStore = TestStore(initialState: .init(intent: intent, institution: institution)) {
            PaymentFeature()
        }

        await testStore.send(._internal(.updatedPayment(failedUpdate))) {
            $0.identifier = failedUpdate.paymentIdentifier
            $0.progressState = failedUpdate.progressState
        }
        await testStore.receive(\.delegate.onUpdatedPayment)
        await testStore.receive(\._internal.paymentFailed)
        await testStore.finish()
    }

    @Test("When identifier has delayedAtBank status, then cancellation API is not called")
    func testCancellationSkippedForDelayedAtBank() async throws {
        nonisolated(unsafe) var cancelPaymentCalled = false
        let delayedIdentifier = PaymentIdentifier(id: "test-payment", token: "test-token", status: .delayedAtBank)

        var testState = PaymentFeature.State(intent: intent, institution: institution)
        testState.identifier = delayedIdentifier
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.voltAPI.cancelPayment = { _, _ in cancelPaymentCalled = true }
        }
        testStore.exhaustivity = .off

        await testStore.send(._internal(.cancelPaymentIfPossible))
        await testStore.finish()

        #expect(cancelPaymentCalled == false)
    }

    @Test("When feedback sheet is submitted, then return to merchant delegate action is sent")
    func testFeedbackSheetSubmitSendsReturnToMerchant() async throws {
        let testState = PaymentFeature.State(intent: intent, institution: institution)
        let testStore = TestStore(initialState: testState) {
            PaymentFeature()
        } withDependencies: {
            $0.voltAPI.cancelPayment = { _, _ in }
        }
        testStore.exhaustivity = .off

        await testStore.send(._internal(.navBar(.delegate(.onSubmitFeedback))))
        await testStore.receive(\._internal.cancelPaymentIfPossible)
        await testStore.receive(\.delegate.onReturnToMerchant)
        await testStore.finish()
    }
}
