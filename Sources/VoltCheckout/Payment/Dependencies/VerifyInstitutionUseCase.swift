//
// VerifyInstitutionUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 17/02/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct VerifyInstitutionUseCase {
    var verify: @Sendable (_ institution: Institution) async throws -> Institution.Item
}

extension VerifyInstitutionUseCase: DependencyKey {
    static let liveValue = Self { institution in
        @Dependency(\.voltAPI.getInstitution) var getInstitution

        let institutionItem = try await getInstitution(institution.id)

        guard institutionItem.isActive else {
            throw PaymentError.institutionNotActive
        }

        return institutionItem
    }
}

extension DependencyValues {
    var verifyInstitution: VerifyInstitutionUseCase {
        get { self[VerifyInstitutionUseCase.self] }
        set { self[VerifyInstitutionUseCase.self] = newValue }
    }
}

extension VerifyInstitutionUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
