//
// CheckoutResultUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 27/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct CheckoutResultUseCase {
    var resultTask: @Sendable () -> Task<CheckoutResult?, Never> = { Task { nil } }
    var yieldResult: @Sendable (_ result: CheckoutResult?) -> Void
}

extension CheckoutResultUseCase: DependencyKey {
    static let liveValue = Self {
        Task {
            let results = NotificationCenter.default
                .notifications(named: .voltCheckoutDidFinishFlow)
                .map { $0.object as? CheckoutResult }
            for await result in results {
                return result
            }
            return nil
        }
    } yieldResult: { result in
        NotificationCenter.default
            .post(name: .voltCheckoutDidFinishFlow, object: result)
    }
}

extension DependencyValues {
    var checkoutResult: CheckoutResultUseCase {
        get { self[CheckoutResultUseCase.self] }
        set { self[CheckoutResultUseCase.self] = newValue }
    }
}

extension CheckoutResultUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
