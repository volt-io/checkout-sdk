//
// InstitutionsCountriesUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct InstitutionsCountriesUseCase {
    var getCountries: @Sendable (_ currency: Currency) async throws -> [Country]
    var preselectCountry: @Sendable (_ defaultCountry: Country?, _ countries: [Country]) -> Country?
}

extension InstitutionsCountriesUseCase: DependencyKey {
    static let liveValue = Self { currency in
        @Dependency(\.voltAPI.getInstitutionsCountries) var getCountries

        if let country = currency.country {
            return [country]
        }
        return try await getCountries(currency)
    } preselectCountry: { defaultCountry, countries in
        if countries.count == 1 {
            countries[0]
        } else if let defaultCountry, countries.contains(defaultCountry) {
            defaultCountry
        } else {
            nil
        }
    }
}

extension DependencyValues {
    var countries: InstitutionsCountriesUseCase {
        get { self[InstitutionsCountriesUseCase.self] }
        set { self[InstitutionsCountriesUseCase.self] = newValue }
    }
}

extension InstitutionsCountriesUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
