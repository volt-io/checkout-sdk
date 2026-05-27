//
// ResolvePaymentProgressUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct ResolvePaymentProgressUseCase {
    var resolve: @Sendable (_ response: PaymentResponse) -> PaymentProgressState = { _ in .verifying }
}

extension ResolvePaymentProgressUseCase: DependencyKey {
    static let liveValue = Self { response in
        let provider: String?
        if Currency(rawValue: response.currency) == .GBP {
            provider = response.openBankingUK?.provider
        } else {
            provider = response.openBankingEU?.provider
        }

        return {
            if response.status.isSuccess {
                .succeeded
            } else if response.status.isError {
                .failed(error: .failed(response.status))
            } else if response.status.isDelayed {
                .delayed
            } else if response.isInputRequired {
                .processing(provider: provider)
            } else if response.isRedirectPossible, let url = response.redirectURL {
                .awaitingRedirect(url: url)
            } else {
                .processing(provider: provider)
            }
        }()
    }
}

extension PaymentStatus {
    static let successStatuses: [Self] = [
        .completed,
        .received,
        .settled,
    ]

    static let errorStatuses: [Self] = [
        .providerCommunicationError,
        .abandonedByUser,
        .cancelledByUser,
        .refusedByBank,
        .refusedByRisk,
        .errorAtBank,
        .failed,
        .unknown,
    ]

    var isSuccess: Bool {
        Self.successStatuses.contains(self)
    }

    var isDelayed: Bool {
        self == .delayedAtBank
    }

    var isError: Bool {
        Self.errorStatuses.contains(self)
    }
}

extension PaymentResponse {
    var isInputRequired: Bool {
        paymentInitiationFlow.status == .waitingForInput &&
        !(paymentInitiationFlow.requiredInput ?? []).isEmpty
    }

    var isRedirectPossible: Bool {
        paymentInitiationFlow.details.reason == .awaitingUserRedirect &&
        paymentInitiationFlow.details.redirect?.url != nil
    }

    var redirectURL: URL? {
        if let urlString = paymentInitiationFlow.details.redirect?.url {
            return URL(string: urlString)
        }
        return nil
    }
}

extension DependencyValues {
    var paymentStatusResolver: ResolvePaymentProgressUseCase {
        get { self[ResolvePaymentProgressUseCase.self] }
        set { self[ResolvePaymentProgressUseCase.self] = newValue }
    }
}

extension ResolvePaymentProgressUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
