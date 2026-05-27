//
// GetPaymentStatusUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 21/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import AsyncAlgorithms
import ComposableArchitecture
import Foundation

@DependencyClient
struct GetPaymentStatusUseCase {
    typealias Update = (paymentIdentifier: PaymentIdentifier, progressState: PaymentProgressState)

    var status: @Sendable (
        _ paymentIdentifier: PaymentIdentifier
    ) -> AsyncThrowingChannel<Update, Error> = { _ in .init() }
}

private let maxRetryCount = 15
private let suspendDuration = Duration.seconds(1)

extension GetPaymentStatusUseCase: DependencyKey {
    static let liveValue = Self { paymentIdentifier in
        @Dependency(\.voltAPI.getPayment) var getPayment
        @Dependency(\.paymentStatusResolver) var statusResolver
        @Dependency(\.suspendingClock) var clock

        let channel = AsyncThrowingChannel<Update, Error>()
        Task {
            var remainingRetries = maxRetryCount
            var paymentIdentifier = paymentIdentifier
            do {
                while remainingRetries > 0, !Task.isCancelled {
                    let response = try await getPayment(paymentIdentifier.id, paymentIdentifier.token)
                    let progressState = statusResolver.resolve(response: response)
                    paymentIdentifier.status = response.status

                    await channel.send((paymentIdentifier, progressState))

                    guard case .processing = progressState else {
                        channel.finish()
                        return
                    }

                    remainingRetries -= 1
                    try await clock.sleep(for: suspendDuration)
                }
            } catch {
                channel.fail(error)
                return
            }
            channel.fail(PaymentError.maxRetriesReached)
        }
        return channel
    }
}

extension DependencyValues {
    var paymentStatus: GetPaymentStatusUseCase {
        get { self[GetPaymentStatusUseCase.self] }
        set { self[GetPaymentStatusUseCase.self] = newValue }
    }
}

extension GetPaymentStatusUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
