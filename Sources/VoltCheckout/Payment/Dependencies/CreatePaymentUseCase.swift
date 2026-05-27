//
// CreatePaymentUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 21/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct CreatePaymentUseCase {
    var create: @Sendable (
        _ intent: PaymentIntent,
        _ institution: Institution,
        _ accountIdentifiersData: AccountIdentifiersData
    ) async throws -> PaymentIdentifier
}

extension CreatePaymentUseCase: DependencyKey {
    static let liveValue = Self { intent, institution, accountIdentifiersData in
        @Dependency(\.voltAPI.createPayment) var createPayment

        let request = request(with: intent, institution, accountIdentifiersData)
        let response = try await createPayment(request)
        return try PaymentIdentifier(response: response)
    }
}

extension CreatePaymentUseCase {
    private static func request(
        with intent: PaymentIntent,
        _ institution: Institution,
        _ accountIdentifiers: AccountIdentifiersData
    ) -> PaymentRequest {
        let paymentSystem: PaymentSystem
        var openBankingEU: PaymentRequest.OpenBankingRequest?
        var openBankingUK: PaymentRequest.OpenBankingRequest?

        let accountIdentifiers = AccountIdentifiers(
            iban: accountIdentifiers.IBAN?.sanitizedValue,
            psuId: accountIdentifiers.PSUId?.sanitizedValue,
            branchCode: accountIdentifiers.branchCode?.sanitizedValue,
            accountNumber: accountIdentifiers.accountNumber?.sanitizedValue
        )
        let openBankingRequest = PaymentRequest.OpenBankingRequest(
            type: intent.transactionType.paymentType,
            institutionId: institution.id,
            accountIdentifiers: accountIdentifiers
        )

        if intent.amount.currency == .GBP {
            paymentSystem = .openBankingUK
            openBankingUK = openBankingRequest
        } else {
            paymentSystem = .openBankingEU
            openBankingEU = openBankingRequest
        }

        return PaymentRequest(
            currency: intent.amount.currency.rawValue,
            amount: intent.amount.minorUnits,
            paymentReference: intent.references?.paymentReference,
            internalReference: intent.references?.internalReference,
            payer: intent.payer.requestPayer,
            device: PaymentRequest.Device(
                ip: "1.1.1.1", // TODO: remove ip address when backend implement taking it from the request
                userAgent: "TODO USER AGENT / VOLT_SDK \(VoltCheckout.version.value)" // TODO: set proper user agent
            ),
            paymentSystem: paymentSystem,
            openBankingEU: openBankingEU,
            openBankingUK: openBankingUK
        )
    }
}

extension TransactionType {
    var paymentType: PaymentType {
        switch self {
        case .bill:
            .bill
        case .goods:
            .goods
        case .services:
            .services
        case .other:
            .other
        }
    }
}

extension Payer {
    var requestPayer: PaymentRequest.Payer {
        var firstName: String?
        var lastName: String?
        var orgName: String?

        switch entity {
        case let .person(person):
            firstName = person.firstName
            lastName = person.lastName
        case let .organization(organization):
            orgName = organization.name
        case let .both(person, organization):
            firstName = person.firstName
            lastName = person.lastName
            orgName = organization.name
        }

        return PaymentRequest.Payer(
            reference: reference.value,
            firstName: firstName,
            lastName: lastName,
            organizationName: orgName,
            email: email,
            phoneNumber: phone
        )
    }
}

extension DependencyValues {
    var createPayment: CreatePaymentUseCase {
        get { self[CreatePaymentUseCase.self] }
        set { self[CreatePaymentUseCase.self] = newValue }
    }
}

extension CreatePaymentUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
